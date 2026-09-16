/**
 * Client for daemon.js. Sends one command over the Unix socket;
 * auto-spawns the daemon if it isn't running yet.
 */

import net from "node:net";
import { spawn } from "node:child_process";
import { tmpdir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const SOCKET_PATH = join(tmpdir(), "web-browser-cdp.sock");
const DAEMON_PATH = join(dirname(fileURLToPath(import.meta.url)), "daemon.js");

function request(cmd, args = {}, timeout = 60000) {
  return new Promise((resolve, reject) => {
    const conn = net.connect(SOCKET_PATH);
    const timeoutId = setTimeout(() => {
      conn.destroy();
      reject(new Error(`Request timeout: ${cmd}`));
    }, timeout);
    let buf = "";
    conn.on("connect", () => conn.write(JSON.stringify({ cmd, ...args }) + "\n"));
    conn.on("data", (chunk) => {
      buf += chunk.toString();
    });
    conn.on("end", () => {
      clearTimeout(timeoutId);
      try {
        const reply = JSON.parse(buf);
        reply.ok ? resolve(reply.result) : reject(new Error(reply.error));
      } catch (e) {
        reject(new Error(`Bad daemon reply: ${e.message}`));
      }
    });
    conn.on("error", (e) => {
      clearTimeout(timeoutId);
      reject(e);
    });
  });
}

export async function call(cmd, args = {}, timeout = 60000) {
  try {
    return await request(cmd, args, timeout);
  } catch (e) {
    // Daemon not running (or stale socket) — spawn it and retry.
    if (e.code !== "ECONNREFUSED" && e.code !== "ENOENT") throw e;
  }

  spawn(process.execPath, [DAEMON_PATH], { detached: true, stdio: "ignore" }).unref();

  let lastErr;
  for (let i = 0; i < 20; i++) {
    await new Promise((r) => setTimeout(r, 150));
    try {
      return await request(cmd, args, timeout);
    } catch (e) {
      // Daemon replied with a command error — real failure, don't keep retrying.
      if (e.code !== "ECONNREFUSED" && e.code !== "ENOENT") throw e;
      lastErr = e;
    }
  }
  throw new Error(
    `Daemon failed to start (${lastErr?.message}) — is Chrome running on :9222? Run start.js first.`
  );
}
