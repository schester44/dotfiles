import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { basename, isAbsolute, join, resolve } from "node:path";
import { mkdir, readFile, writeFile, stat, utimes } from "node:fs/promises";
import { createHash } from "node:crypto";

/**
 * Minimal session-move extension.
 *
 * /move <target-directory>  — copy the current session to a new cwd bucket
 *                             with path strings rewritten, then switch into it.
 *
 * Inspired by pi-session-move but without lineage tracking, SQLite stores,
 * prune management, or restart scripts.
 */

// ── Path helpers ──────────────────────────────────────────────────────

function expandTilde(value: string): string {
  if (value === "~" || value.startsWith("~/")) {
    const home = process.env.HOME;
    if (!home) throw new Error("Cannot expand ~: HOME is not set.");
    return value === "~" ? home : join(home, value.slice(2));
  }
  return value;
}

function normalizeDir(value: string): string {
  return resolve(expandTilde(value.replace(/\\(.)/g, "$1")));
}

function resolveTarget(value: string, baseCwd: string): string {
  const expanded = expandTilde(value.replace(/\\(.)/g, "$1"));
  return normalizeDir(isAbsolute(expanded) ? expanded : resolve(baseCwd, expanded));
}

/** Pi stores sessions in ~/.pi/agent/sessions/--path-segments--/ */
function sessionBucketName(cwd: string): string {
  const normalized = normalizeDir(cwd).replace(/[/\\]+$/g, "");
  const withoutRoot = normalized.replace(/^[/\\]+/, "");
  return `--${withoutRoot.replace(/[/\\:]+/g, "-")}--`;
}

function agentDir(): string {
  return (
    process.env.PI_CODING_AGENT_DIR ??
    join(process.env.HOME ?? ".", ".pi", "agent")
  );
}

function shortPath(path: string): string {
  const home = process.env.HOME;
  return home && path.startsWith(`${home}/`)
    ? `~/${path.slice(home.length + 1)}`
    : path;
}

// ── Core rewrite logic ────────────────────────────────────────────────

function replaceCwdInSession(
  input: string,
  aliases: string[],
  targetCwd: string
): { text: string; replacements: number } {
  let text = input;
  let replacements = 0;

  for (const alias of [...new Set(aliases.filter(Boolean))]) {
    if (!alias || alias === targetCwd) continue;

    const before = text;
    // Replace literal path and escaped-slash variant (JSON strings)
    text = text.split(alias).join(targetCwd);
    text = text
      .split(alias.replace(/\//g, "\\/"))
      .join(targetCwd.replace(/\//g, "\\/"));

    if (before !== text) {
      replacements += before.split(alias).length - 1;
    }
  }

  return { text, replacements };
}

function uniqueRelocatedName(originalFile: string): string {
  const parsed = basename(originalFile).replace(/\.jsonl$/i, "");
  const sessionId = parsed.split("_relocated_")[0] || "session";
  const suffix = createHash("sha256")
    .update(`${originalFile}\0${Date.now()}\0${Math.random()}`)
    .digest("hex")
    .slice(0, 12);
  return `${sessionId.slice(0, 80)}_relocated_${suffix}.jsonl`;
}

// ── Extension ─────────────────────────────────────────────────────────

export default function(pi: ExtensionAPI) {
  pi.registerCommand("move", {
    description:
      "Move this session to another cwd. Rewrites path strings and switches into the copy. Usage: /move <target-directory>",
    handler: async (args, ctx) => {
      const target = args.trim();
      if (!target) {
        ctx.ui.notify(
          "Usage: /move <target-directory>\n\nExample: /move ~/work/risk-management",
          "error"
        );
        return;
      }

      const sessionFile = ctx.sessionManager.getSessionFile();
      if (!sessionFile) {
        ctx.ui.notify("Cannot move an ephemeral session.", "error");
        return;
      }

      const oldCwd = normalizeDir(ctx.cwd);
      const targetCwd = resolveTarget(target, ctx.cwd);

      // Validate target
      const targetStat = await stat(targetCwd).catch(() => undefined);
      if (targetStat && !targetStat.isDirectory()) {
        ctx.ui.notify(
          `Target exists but is not a directory: ${targetCwd}`,
          "error"
        );
        return;
      }

      if (oldCwd === targetCwd) {
        ctx.ui.notify("Target directory is already the current cwd.", "info");
        return;
      }

      // Confirm
      const ok = await ctx.ui.confirm(
        "Move session?",
        [
          "This will copy the session with path strings rewritten and switch into it.",
          "",
          `From: ${shortPath(oldCwd)}`,
          `To:   ${shortPath(targetCwd)}`,
        ].join("\n")
      );
      if (!ok) return;

      await ctx.waitForIdle();

      // Read session
      const original = await readFile(sessionFile, "utf8");

      // Rewrite paths
      const storedCwd = ctx.sessionManager.getCwd();
      const aliases = [
        oldCwd,
        storedCwd,
        storedCwd ? normalizeDir(storedCwd) : "",
      ];
      const { text: relocated, replacements } = replaceCwdInSession(
        original,
        aliases,
        targetCwd
      );

      // Write to new bucket
      const destinationDir = join(
        agentDir(),
        "sessions",
        sessionBucketName(targetCwd)
      );
      await mkdir(destinationDir, { recursive: true });

      if (!targetStat) {
        await mkdir(targetCwd, { recursive: true });
      }

      const destinationFile = join(
        destinationDir,
        uniqueRelocatedName(sessionFile)
      );
      await writeFile(destinationFile, relocated, {
        encoding: "utf8",
        flag: "wx",
      });

      // Touch so `pi -c` in the target dir picks this session
      await utimes(destinationFile, new Date(), new Date());

      ctx.ui.notify(
        [
          `Moved session with ${replacements} path rewrite${replacements === 1 ? "" : "s"}.`,
          "",
          `From: ${shortPath(oldCwd)}`,
          `To:   ${shortPath(targetCwd)}`,
          "",
          "Switching to moved session...",
        ].join("\n"),
        "info"
      );

      // Switch into the new session
      const result = await ctx.switchSession(destinationFile, {
        withSession: async (nextCtx) => {
          nextCtx.ui.notify(
            [
              "✓ Session moved successfully",
              "",
              `Now in: ${shortPath(targetCwd)}`,
              `Session: ${shortPath(destinationFile)}`,
              "",
              "To resume later:",
              `  cd ${targetCwd}`,
              "  pi -c",
            ].join("\n"),
            "info"
          );
        },
      });

      if (result?.cancelled) {
        ctx.ui.notify(
          [
            "Session switch was cancelled by an extension.",
            "",
            "The moved session file was still written:",
            shortPath(destinationFile),
            "",
            "To resume manually:",
            `  cd ${targetCwd}`,
            `  pi --session ${destinationFile}`,
          ].join("\n"),
          "warning"
        );
      }
    },
  });
}
