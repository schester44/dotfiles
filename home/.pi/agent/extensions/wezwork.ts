// Managed by wezwork. Reinstalling the integration overwrites this file.
// WEZWORK_PI_INTEGRATION_VERSION=1

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { mkdirSync, readFileSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { isAbsolute, join, resolve } from "node:path";

const USER_VAR = "wezwork_pi";
const VERSION = 1;
const paneId = /^\d+$/.test(process.env.WEZTERM_PANE ?? "") ? process.env.WEZTERM_PANE : undefined;
const home = process.env.HOME ?? "";
function normalizeStateRoot(value: string): string {
  const expanded = value === "~" ? home : value.startsWith("~/") ? join(home, value.slice(2)) : value;
  return isAbsolute(expanded) ? expanded : resolve(home, expanded);
}
const stateRoot = normalizeStateRoot(process.env.WEZWORK_STATE_DIR
  ?? (process.env.XDG_STATE_HOME
    ? join(process.env.XDG_STATE_HOME, "wezwork")
    : join(home, ".local", "state", "wezwork")));
const registryDir = join(stateRoot, "live");
const registryFile = paneId ? join(registryDir, `${paneId}-${process.pid}.json`) : undefined;
const instanceId = `${process.pid}-${Date.now()}-${Math.random().toString(36).slice(2)}`;

type SessionState = "idle" | "working";

function setUserVar(value: string): void {
  if (!process.env.WEZTERM_PANE || !process.stdout.isTTY) return;
  const encoded = Buffer.from(value, "utf8").toString("base64");
  process.stdout.write(`\x1b]1337;SetUserVar=${USER_VAR}=${encoded}\x07`);
}

function clearUserVar(): void {
  if (!process.env.WEZTERM_PANE || !process.stdout.isTTY) return;
  process.stdout.write(`\x1b]1337;SetUserVar=${USER_VAR}=\x07`);
}

function writeRegistry(value: string): void {
  if (!registryFile) return;
  try {
    mkdirSync(registryDir, { recursive: true, mode: 0o700 });
    const temporary = `${registryFile}.${process.pid}.tmp`;
    writeFileSync(temporary, value, { encoding: "utf8", mode: 0o600 });
    renameSync(temporary, registryFile);
  } catch {
    // Session discovery must never interfere with Pi.
  }
}

function clearRegistry(): void {
  if (!registryFile) return;
  try {
    const current = JSON.parse(readFileSync(registryFile, "utf8"));
    if (current?.instanceId === instanceId) rmSync(registryFile, { force: true });
  } catch {
    // Best-effort cleanup; wezwork also rejects stale heartbeat records.
  }
}

export default function(pi: ExtensionAPI) {
  let enabled = false;
  let state: SessionState = "idle";
  let latest: Record<string, unknown> | undefined;
  let heartbeat: ReturnType<typeof setInterval> | undefined;

  function flush(): void {
    if (!enabled || !latest) return;
    latest.updatedAt = new Date().toISOString();
    const payload = JSON.stringify(latest);
    // OSC makes the metadata available to WezTerm Lua. The registry is needed
    // because `wezterm cli list --format json` does not expose pane user vars.
    setUserVar(payload);
    writeRegistry(payload);
  }

  function publish(ctx: ExtensionContext): void {
    if (!enabled) return;
    const usage = ctx.getContextUsage();
    const model = ctx.model ? { provider: ctx.model.provider, id: ctx.model.id } : undefined;

    latest = {
      version: VERSION,
      instanceId,
      pid: process.pid,
      weztermPane: process.env.WEZTERM_PANE,
      sessionId: ctx.sessionManager.getSessionId(),
      sessionFile: ctx.sessionManager.getSessionFile(),
      sessionName: pi.getSessionName(),
      cwd: ctx.cwd,
      state,
      model,
      thinkingLevel: ctx.thinkingLevel,
      entryCount: ctx.sessionManager.getEntries().length,
      contextTokens: usage?.tokens,
      contextWindow: usage?.contextWindow,
    };
    flush();
  }

  pi.on("session_start", (_event, ctx) => {
    // SetUserVar is terminal-specific, so never emit it into JSON/RPC/print output.
    enabled = ctx.mode === "tui" && !!paneId && process.stdout.isTTY;
    state = ctx.isIdle() ? "idle" : "working";
    publish(ctx);
    if (enabled && !heartbeat) {
      heartbeat = setInterval(flush, 3000);
      heartbeat.unref?.();
    }
  });

  pi.on("agent_start", (_event, ctx) => {
    state = "working";
    publish(ctx);
  });

  pi.on("agent_settled", (_event, ctx) => {
    state = "idle";
    publish(ctx);
  });

  pi.on("session_info_changed", (_event, ctx) => publish(ctx));
  pi.on("model_select", (_event, ctx) => publish(ctx));
  pi.on("thinking_level_select", (_event, ctx) => publish(ctx));
  pi.on("session_compact", (_event, ctx) => publish(ctx));
  pi.on("session_tree", (_event, ctx) => publish(ctx));

  pi.on("session_shutdown", () => {
    enabled = false;
    if (heartbeat) clearInterval(heartbeat);
    heartbeat = undefined;
    clearUserVar();
    clearRegistry();
    latest = undefined;
  });
}
