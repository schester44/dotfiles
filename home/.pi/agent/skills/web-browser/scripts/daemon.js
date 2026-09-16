#!/usr/bin/env node
/**
 * Persistent CDP daemon.
 *
 * Connects to Chrome (:9222) ONCE and serves commands over a Unix socket,
 * eliminating the per-command connect/attach/teardown tax (~300-800ms → ~5ms).
 *
 * Auto-spawned by client.js on first use. Exits when Chrome closes or after
 * 60 minutes idle. Protocol: newline-delimited JSON, one request per connection.
 *   → { cmd: "eval"|"nav"|"screenshot"|"pages"|"ping"|"shutdown", ...args }
 *   ← { ok: true, result } | { ok: false, error }
 */

import net from "node:net";
import fs from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { connect } from "./cdp.js";

export const SOCKET_PATH = join(tmpdir(), "web-browser-cdp.sock");
const IDLE_LIMIT_MS = 60 * 60 * 1000;

const cdp = await connect(5000);

// One attached session per target, created lazily, dropped on detach.
const sessions = new Map(); // targetId -> sessionId

cdp.onEvent((msg) => {
  if (msg.method === "Target.detachedFromTarget") {
    for (const [tid, sid] of sessions) {
      if (sid === msg.params.sessionId) sessions.delete(tid);
    }
  }
});

cdp.onClose(() => {
  try {
    fs.unlinkSync(SOCKET_PATH);
  } catch {}
  process.exit(0);
});

async function getSession(targetId = null) {
  if (!targetId) {
    const pages = await cdp.getPages();
    const page = pages.at(-1);
    if (!page) throw new Error("No active tab found");
    targetId = page.targetId;
  }
  let sessionId = sessions.get(targetId);
  if (!sessionId) {
    sessionId = await cdp.attachToPage(targetId);
    await cdp.send("Page.enable", {}, sessionId).catch(() => {});
    await cdp
      .send("Page.setLifecycleEventsEnabled", { enabled: true }, sessionId)
      .catch(() => {});
    sessions.set(targetId, sessionId);
  }
  return sessionId;
}

/** Resolve true when a lifecycle event (e.g. networkIdle) fires, false on timeout. */
function waitForLifecycle(sessionId, name, timeout) {
  return new Promise((resolve) => {
    const timeoutId = setTimeout(() => {
      off();
      resolve(false);
    }, timeout);
    const off = cdp.onEvent((msg) => {
      if (
        msg.method === "Page.lifecycleEvent" &&
        msg.sessionId === sessionId &&
        msg.params.name === name
      ) {
        clearTimeout(timeoutId);
        off();
        resolve(true);
      }
    });
  });
}

const handlers = {
  async ping() {
    return "pong";
  },

  async pages() {
    return (await cdp.getPages()).map((p) => ({
      targetId: p.targetId,
      url: p.url,
      title: p.title,
    }));
  },

  async eval({ code, timeout = 30000 }) {
    const sessionId = await getSession();
    const expression = `(async () => { return (${code}); })()`;
    return cdp.evaluate(sessionId, expression, timeout);
  },

  // wait: "load" (default) | "idle" (network idle — catches late XHR/banners) | false
  async nav({ url, newTab = false, wait = "load", waitTimeout = 15000 }) {
    let targetId;
    const noTabs = (await cdp.getPages()).length === 0;
    if (newTab || noTabs) {
      ({ targetId } = await cdp.send("Target.createTarget", { url: "about:blank" }));
    }
    const sessionId = await getSession(targetId);
    let loaded = Promise.resolve(null);
    if (wait === "idle") {
      loaded = waitForLifecycle(sessionId, "networkIdle", waitTimeout);
    } else if (wait) {
      loaded = cdp.waitForEvent("Page.loadEventFired", sessionId, waitTimeout).then(
        () => true,
        () => false
      );
    }
    await cdp.navigate(sessionId, url);
    const didLoad = await loaded;
    return { url, newTab, loaded: didLoad };
  },

  /**
   * Wait for a condition without polling from outside — resolves the instant
   * it's true. Exactly one of:
   *   selector: CSS selector appears in DOM (MutationObserver)
   *   gone:     CSS selector disappears from DOM
   *   js:       arbitrary JS expression becomes truthy (checked on DOM mutations + 250ms tick)
   */
  async waitFor({ selector, gone, js, timeout = 15000 }) {
    const sessionId = await getSession();
    let condition;
    if (selector) condition = `!!document.querySelector(${JSON.stringify(selector)})`;
    else if (gone) condition = `!document.querySelector(${JSON.stringify(gone)})`;
    else if (js) condition = `(${js})`;
    else throw new Error("waitFor needs selector, gone, or js");

    const expression = `
      new Promise((resolve, reject) => {
        const check = () => { try { return ${condition}; } catch { return false; } };
        if (check()) return resolve(true);
        const obs = new MutationObserver(() => { if (check()) done(true); });
        const tick = setInterval(() => { if (check()) done(true); }, 250);
        const kill = setTimeout(() => done(false), ${timeout});
        function done(ok) {
          obs.disconnect(); clearInterval(tick); clearTimeout(kill);
          ok ? resolve(true) : reject(new Error("waitFor timeout after ${timeout}ms"));
        }
        obs.observe(document.documentElement, { childList: true, subtree: true, attributes: true });
      })
    `;
    return cdp.evaluate(sessionId, expression, timeout + 2000);
  },

  async screenshot() {
    const sessionId = await getSession();
    const data = await cdp.screenshot(sessionId);
    const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
    const filepath = join(tmpdir(), `screenshot-${timestamp}.png`);
    fs.writeFileSync(filepath, data);
    return filepath;
  },

  async shutdown() {
    setTimeout(() => process.exit(0), 50);
    return "bye";
  },
};

let lastActivity = Date.now();
setInterval(() => {
  if (Date.now() - lastActivity > IDLE_LIMIT_MS) {
    try {
      fs.unlinkSync(SOCKET_PATH);
    } catch {}
    process.exit(0);
  }
}, 60 * 1000).unref();

try {
  fs.unlinkSync(SOCKET_PATH);
} catch {}

const server = net.createServer((conn) => {
  let buf = "";
  conn.on("data", async (chunk) => {
    buf += chunk.toString();
    const nl = buf.indexOf("\n");
    if (nl === -1) return;
    lastActivity = Date.now();
    let reply;
    try {
      const req = JSON.parse(buf.slice(0, nl));
      const handler = handlers[req.cmd];
      if (!handler) throw new Error(`Unknown command: ${req.cmd}`);
      reply = { ok: true, result: await handler(req) };
    } catch (e) {
      reply = { ok: false, error: e.message };
    }
    conn.end(JSON.stringify(reply) + "\n");
  });
  conn.on("error", () => {});
});

server.listen(SOCKET_PATH);
process.on("SIGTERM", () => {
  try {
    fs.unlinkSync(SOCKET_PATH);
  } catch {}
  process.exit(0);
});
