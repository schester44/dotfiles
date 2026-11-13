// wezzy agent status: tells Wezzy what pi is doing, for the sidebar.
// Installed by Wezzy (Settings → Agent hooks); safe to delete.
// Only active inside Wezzy panes, so pi in other terminals is unaffected.

import { mkdirSync, renameSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const pane = process.env.WEZTERM_PANE ?? "";
const inWezzy = !!(process.env.WEZZY || process.env.DEKITA) && /^\d+$/.test(pane);
const dir = join(
  process.env.XDG_STATE_HOME || join(process.env.HOME ?? "", ".local/state"),
  "wezzy/agents",
);

function report(payload: Record<string, unknown>): void {
  try {
    mkdirSync(dir, { recursive: true });
    const tmp = join(dir, `.${pane}.${process.pid}`);
    const record = { harness: "pi", pane: Number(pane), ts: Math.floor(Date.now() / 1000), payload };
    writeFileSync(tmp, JSON.stringify(record) + "\n");
    renameSync(tmp, join(dir, `${pane}.json`));
  } catch {
    // status reporting must never get in pi's way
  }
}

// Just enough of a tool's arguments to describe it ("Editing app.rs").
function brief(args: any): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const k of ["path", "file_path", "command", "description", "pattern"]) {
    if (typeof args?.[k] === "string") out[k] = args[k].slice(0, 200);
  }
  return out;
}

export default function (pi: any) {
  if (!inWezzy) return;
  // Only the interactive session owns the pane: print, json and rpc runs
  // (subagents) inherit WEZTERM_PANE too and must stay quiet.
  let on = false;
  let cwd: string | undefined;
  let prompting = false;
  const send = (event: string, extra: Record<string, unknown> = {}) => {
    if (on) report({ event, cwd, ...extra });
  };

  pi.on("session_start", (_e: any, ctx: any) => {
    on = ctx.mode === "tui" && !!process.stdout.isTTY;
    cwd = ctx.cwd;
    send("session_start");
  });
  pi.on("agent_start", () => send("agent_start"));
  pi.on("tool_execution_start", (e: any) =>
    send("tool_execution_start", { tool: e.toolName, input: brief(e.args) }),
  );
  pi.on("tool_execution_end", () => send("tool_execution_end"));
  pi.on("session_before_compact", () => send("session_before_compact"));
  pi.on("ui_prompt_start", (e: any, ctx: any) => {
    if (ctx.isIdle()) return; // a dialog you opened yourself
    prompting = true;
    send("ui_prompt_start", { message: e.title });
  });
  pi.on("ui_prompt_end", (_e: any, ctx: any) => {
    if (!prompting) return;
    prompting = false;
    send("ui_prompt_end", { idle: ctx.isIdle() });
  });
  pi.on("agent_settled", () => send("agent_settled"));
  pi.on("session_shutdown", (e: any) => {
    if (e.reason === "quit") send("session_shutdown");
  });
}
