/**
 * GitHub Actions Monitor Extension
 *
 * Polls GitHub Actions workflow runs when on a non-main branch and displays
 * their status in a widget. Shows:
 * - Running workflows with elapsed time
 * - Completed workflows with success/failure status
 * - Auto-hides when no recent runs
 *
 * The extension also notifies the model when runs complete via silent messages,
 * so it can react to CI failures.
 */

import type { ExtensionAPI, ExtensionContext, TUI, Theme } from "@mariozechner/pi-coding-agent";
import { spawn } from "node:child_process";

interface WorkflowRun {
  id: number;
  name: string;
  status: "queued" | "in_progress" | "completed";
  conclusion: "success" | "failure" | "cancelled" | "skipped" | null;
  startedAt: string;
  updatedAt: string;
  headBranch: string;
  headSha: string;
  htmlUrl: string;
}

interface Job {
  name: string;
  status: "queued" | "in_progress" | "completed";
  conclusion: "success" | "failure" | "cancelled" | "skipped" | null;
}

interface TrackedRun {
  run: WorkflowRun;
  jobs: Job[];
  startTime: number;
  notified: boolean;
  failedJobsNotified: Set<string>; // Track which failed jobs we've already notified about
}

// Track fix attempts per workflow name (persists across runs of same workflow)
const fixAttempts: Map<string, number> = new Map();
const MAX_FIX_ATTEMPTS = 5;

// State
let trackedRuns: Map<number, TrackedRun> = new Map();
let pollInterval: ReturnType<typeof setInterval> | null = null;
let widgetTui: TUI | null = null;
let currentBranch: string | null = null;
let lastCommit: string | null = null;
let lastCwd: string | null = null;
let lastActiveTime: number = Date.now(); // Track when we last saw active runs

const POLL_INTERVAL_MS = 15_000; // 15 seconds
const LINGER_TIME_MS = 30_000; // Keep completed runs visible for 30s
const IDLE_STOP_MS = 120_000; // Stop polling after 2 minutes of no active runs

export default function githubActionsMonitorExtension(pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    await initMonitor(ctx, pi);
  });

  pi.on("session_switch", async (_event, ctx) => {
    stopPolling();
    trackedRuns.clear();
    await initMonitor(ctx, pi);
  });

  pi.on("session_shutdown", async () => {
    stopPolling();
  });

  // Check on turn end - branch or commit might have changed (new push)
  pi.on("turn_end", async (_event, ctx) => {
    const newBranch = await getCurrentBranch(ctx.cwd);
    const newCommit = await getHeadCommit(ctx.cwd);

    const branchChanged = newBranch !== currentBranch;
    const commitChanged = newCommit && newCommit !== lastCommit;

    if (branchChanged || commitChanged) {
      currentBranch = newBranch;
      if (branchChanged) {
        trackedRuns.clear();
      }

      // Restart polling on new commits
      if (commitChanged && newBranch && newBranch !== "main" && newBranch !== "master") {
        lastActiveTime = Date.now();
        startPolling(ctx.cwd, pi);
      }

      await pollOnce(ctx.cwd, pi);
      widgetTui?.requestRender();
    }
  });
}

async function initMonitor(ctx: ExtensionContext, pi: ExtensionAPI) {
  lastCwd = ctx.cwd;
  currentBranch = await getCurrentBranch(ctx.cwd);

  if (!currentBranch || currentBranch === "main" || currentBranch === "master") {
    // Don't monitor on main/master
    if (ctx.hasUI) {
      ctx.ui.setWidget("github-actions", undefined);
    }
    return;
  }

  if (ctx.hasUI) {
    ctx.ui.setWidget("github-actions", (tui, theme) => {
      widgetTui = tui;
      return {
        render: () => renderWidget(theme),
        invalidate: () => { },
        dispose: () => {
          widgetTui = null;
        },
      };
    });
  }

  // Initial poll
  await pollOnce(ctx.cwd, pi);

  // Start polling
  startPolling(ctx.cwd, pi);
}

function startPolling(cwd: string, pi: ExtensionAPI) {
  stopPolling();
  pollInterval = setInterval(async () => {
    await pollOnce(cwd, pi);
    widgetTui?.requestRender();
  }, POLL_INTERVAL_MS);
}

function stopPolling() {
  if (pollInterval) {
    clearInterval(pollInterval);
    pollInterval = null;
  }
}

async function pollOnce(cwd: string, pi: ExtensionAPI) {
  if (!currentBranch || currentBranch === "main" || currentBranch === "master") {
    return;
  }

  // Get current HEAD commit
  const headCommit = await getHeadCommit(cwd);
  if (!headCommit) return;

  // If HEAD changed, clear old runs
  if (lastCommit && headCommit !== lastCommit) {
    trackedRuns.clear();
  }
  lastCommit = headCommit;

  const runs = await fetchWorkflowRuns(cwd, currentBranch);

  // Only track runs for current HEAD commit
  const currentRuns = runs.filter((run) => run.headSha === headCommit);

  for (const run of currentRuns) {
    const existing = trackedRuns.get(run.id);

    if (!existing) {
      // New run - fetch jobs immediately if in progress
      const jobs = run.status === "in_progress" ? await fetchJobsForRun(cwd, run.id) : [];
      const failedJobs = jobs.filter((j) => j.conclusion === "failure");
      const failedJobsNotified = new Set(failedJobs.map((j) => j.name));

      trackedRuns.set(run.id, {
        run,
        jobs,
        startTime: Date.now(),
        notified: false,
        failedJobsNotified,
      });

      // Notify about any existing failures on first discovery
      if (failedJobs.length > 0) {
        notifyJobFailure(run, failedJobs, pi);
      }
    } else {
      // Update existing
      const wasInProgress =
        existing.run.status === "in_progress" || existing.run.status === "queued";
      const nowComplete = run.status === "completed";

      existing.run = run;

      // Notify on completion (but skip if we already notified about job failures)
      if (wasInProgress && nowComplete && !existing.notified) {
        existing.notified = true;
        // Only notify completion if we haven't already notified about failures
        if (existing.failedJobsNotified.size === 0) {
          notifyCompletion(run, existing.jobs, pi);
        }
      }
    }

    // Fetch job details for in-progress runs to detect early failures
    const tracked = trackedRuns.get(run.id)!;
    if (run.status === "in_progress") {
      const jobs = await fetchJobsForRun(cwd, run.id);
      tracked.jobs = jobs;

      // Check for any newly failed jobs (that we haven't notified about yet)
      const failedJobs = jobs.filter(
        (j) => j.conclusion === "failure" && !tracked.failedJobsNotified.has(j.name)
      );

      if (failedJobs.length > 0) {
        // Mark these jobs as notified
        for (const job of failedJobs) {
          tracked.failedJobsNotified.add(job.name);
        }
        // Notify immediately - don't wait for workflow completion
        notifyJobFailure(run, failedJobs, pi);
      }
    }
  }

  // Clean up old completed runs after linger time
  const now = Date.now();
  for (const [id, tracked] of trackedRuns) {
    if (tracked.run.status === "completed") {
      const completedTime = new Date(tracked.run.updatedAt).getTime();
      if (now - completedTime > LINGER_TIME_MS) {
        trackedRuns.delete(id);
      }
    }
  }

  // Check if any runs are still active
  const hasActiveRuns = Array.from(trackedRuns.values()).some(
    (t) => t.run.status === "in_progress" || t.run.status === "queued"
  );

  if (hasActiveRuns) {
    lastActiveTime = now;
  } else if (now - lastActiveTime > IDLE_STOP_MS) {
    // No active runs for a while, stop polling to save API calls
    stopPolling();
  }
}

function notifyCompletion(run: WorkflowRun, jobs: Job[], pi: ExtensionAPI) {
  const isError = run.conclusion === "failure";
  const icon = run.conclusion === "success" ? "✓" : "✗";
  const status = run.conclusion ?? "unknown";

  // Reset fix attempts on success
  if (run.conclusion === "success") {
    fixAttempts.delete(run.name);
  }

  let content: string;
  let shouldTrigger = false;

  if (isError) {
    const failedJobs = jobs.filter((j) => j.conclusion === "failure");
    const attempts = (fixAttempts.get(run.name) ?? 0) + 1;
    fixAttempts.set(run.name, attempts);

    const failedJobNames = failedJobs.map((j) => j.name).join(", ") || "unknown";

    if (attempts > MAX_FIX_ATTEMPTS) {
      content = `${icon} GitHub Actions: ${run.name} FAILED (attempt ${attempts}/${MAX_FIX_ATTEMPTS})

CI has failed ${attempts} times. Stopping auto-fix to avoid infinite loop.
Failed jobs: ${failedJobNames}
Manual intervention required: ${run.htmlUrl}`;
      shouldTrigger = false;
    } else {
      content = `${icon} GitHub Actions: ${run.name} FAILED (attempt ${attempts}/${MAX_FIX_ATTEMPTS})

CI failed on branch ${run.headBranch}. Failed jobs: ${failedJobNames}

Please investigate and fix:

1. Run \`gh run view ${run.id} --log-failed\` to see the failure logs
2. Identify the root cause
3. Fix the issue and commit the changes

Run URL: ${run.htmlUrl}`;
      shouldTrigger = true;
    }
  } else {
    content = `${icon} GitHub Actions: ${run.name} ${status}`;
  }

  pi.sendMessage(
    {
      customType: "github-actions-complete",
      content,
      display: isError,
      details: {
        runId: run.id,
        name: run.name,
        conclusion: run.conclusion,
        branch: run.headBranch,
        url: run.htmlUrl,
        fixAttempt: isError ? fixAttempts.get(run.name) : undefined,
      },
    },
    {
      triggerTurn: shouldTrigger,
      deliverAs: "followUp",
    }
  );
}

function notifyJobFailure(run: WorkflowRun, failedJobs: Job[], pi: ExtensionAPI) {
  const attempts = (fixAttempts.get(run.name) ?? 0) + 1;
  fixAttempts.set(run.name, attempts);

  const failedJobNames = failedJobs.map((j) => j.name).join(", ");

  let content: string;
  let shouldTrigger = false;

  if (attempts > MAX_FIX_ATTEMPTS) {
    content = `✗ GitHub Actions: ${run.name} - jobs failed (attempt ${attempts}/${MAX_FIX_ATTEMPTS})

CI has failed ${attempts} times. Stopping auto-fix to avoid infinite loop.
Failed jobs: ${failedJobNames}
Manual intervention required: ${run.htmlUrl}`;
    shouldTrigger = false;
  } else {
    content = `✗ GitHub Actions: ${run.name} - jobs failed early (attempt ${attempts}/${MAX_FIX_ATTEMPTS})

CI job failures detected on branch ${run.headBranch}. Failed jobs: ${failedJobNames}

Please investigate and fix:

1. Run \`gh run view ${run.id} --log-failed\` to see the failure logs
2. Identify the root cause  
3. Fix the issue and commit the changes

Run URL: ${run.htmlUrl}`;
    shouldTrigger = true;
  }

  pi.sendMessage(
    {
      customType: "github-actions-job-failure",
      content,
      display: true,
      details: {
        runId: run.id,
        name: run.name,
        failedJobs: failedJobs.map((j) => j.name),
        branch: run.headBranch,
        url: run.htmlUrl,
        fixAttempt: attempts,
      },
    },
    {
      triggerTurn: shouldTrigger,
      deliverAs: "followUp",
    }
  );
}

function renderWidget(theme: Theme): string[] {
  const visible = getVisibleRuns();
  if (visible.length === 0) return []; // Auto-hide

  const parts = visible.map((tracked) => {
    const { run, jobs } = tracked;
    const elapsed = formatElapsed(tracked.startTime);

    if (run.status === "completed") {
      if (run.conclusion === "success") {
        return `${theme.fg("success", "✓")} ${theme.fg("dim", run.name)}`;
      }
      if (run.conclusion === "failure") {
        const failedJobs = jobs.filter((j) => j.conclusion === "failure");
        const failedNames = failedJobs.map((j) => j.name).join(", ");
        return `${theme.fg("error", "✗")} ${theme.fg("text", run.name)}${failedNames ? theme.fg("dim", ` (${failedNames})`) : ""}`;
      }
      // cancelled, skipped, etc.
      return `${theme.fg("warning", "○")} ${theme.fg("dim", run.name)}`;
    }

    // In progress - check for early job failures
    const failedJobs = jobs.filter((j) => j.conclusion === "failure");
    if (failedJobs.length > 0) {
      const failedNames = failedJobs.map((j) => j.name).join(", ");
      return `${theme.fg("error", "✗")} ${theme.fg("text", run.name)} ${theme.fg("dim", `(${failedNames})`)}`;
    }

    // Still running, show progress
    const completedJobs = jobs.filter((j) => j.status === "completed").length;
    const totalJobs = jobs.length;
    const statusIcon = run.status === "queued" ? "◇" : "◆";
    const progress = totalJobs > 0 ? ` ${completedJobs}/${totalJobs}` : "";
    return `${theme.fg("warning", statusIcon)} ${theme.fg("text", run.name)}${theme.fg("muted", progress)} ${theme.fg("dim", elapsed)}`;
  });

  return [parts.join("  ")];
}

function getVisibleRuns(): TrackedRun[] {
  return Array.from(trackedRuns.values()).sort((a, b) => {
    // Active runs first, then by start time
    const aActive = a.run.status !== "completed";
    const bActive = b.run.status !== "completed";
    if (aActive !== bActive) return aActive ? -1 : 1;
    return b.startTime - a.startTime;
  });
}

function formatElapsed(startTime: number): string {
  const seconds = Math.floor((Date.now() - startTime) / 1000);
  if (seconds < 60) return `${seconds}s`;
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;
  return `${minutes}m${remainingSeconds}s`;
}

// Git helpers
async function getCurrentBranch(cwd: string): Promise<string | null> {
  try {
    const result = await runCommand("git", ["rev-parse", "--abbrev-ref", "HEAD"], cwd);
    if (result.code === 0) {
      return result.stdout.trim();
    }
  } catch {
    // Not a git repo
  }
  return null;
}

async function getHeadCommit(cwd: string): Promise<string | null> {
  try {
    const result = await runCommand("git", ["rev-parse", "HEAD"], cwd);
    if (result.code === 0) {
      return result.stdout.trim();
    }
  } catch {
    // Not a git repo
  }
  return null;
}

// GitHub CLI helpers
async function fetchJobsForRun(cwd: string, runId: number): Promise<Job[]> {
  try {
    const result = await runCommand(
      "gh",
      ["run", "view", String(runId), "--json", "jobs"],
      cwd
    );

    if (result.code !== 0) {
      return [];
    }

    const data = JSON.parse(result.stdout);
    return (data.jobs ?? []).map((item: Record<string, unknown>) => ({
      name: item.name,
      status: item.status,
      conclusion: item.conclusion,
    }));
  } catch {
    return [];
  }
}

async function fetchWorkflowRuns(cwd: string, branch: string): Promise<WorkflowRun[]> {
  try {
    const result = await runCommand(
      "gh",
      [
        "run",
        "list",
        "--branch",
        branch,
        "--limit",
        "10",
        "--json",
        "databaseId,name,status,conclusion,startedAt,updatedAt,headBranch,headSha,url",
      ],
      cwd
    );

    if (result.code !== 0) {
      return [];
    }

    const data = JSON.parse(result.stdout);
    return data.map((item: Record<string, unknown>) => ({
      id: item.databaseId,
      name: item.name,
      status: item.status,
      conclusion: item.conclusion,
      startedAt: item.startedAt,
      updatedAt: item.updatedAt,
      headBranch: item.headBranch,
      headSha: item.headSha,
      htmlUrl: item.url,
    }));
  } catch {
    return [];
  }
}

function runCommand(
  cmd: string,
  args: string[],
  cwd: string
): Promise<{ stdout: string; stderr: string; code: number }> {
  return new Promise((resolve) => {
    const proc = spawn(cmd, args, { cwd, stdio: ["ignore", "pipe", "pipe"] });
    let stdout = "";
    let stderr = "";

    proc.stdout.on("data", (d) => (stdout += d.toString()));
    proc.stderr.on("data", (d) => (stderr += d.toString()));

    proc.on("close", (code) => {
      resolve({ stdout, stderr, code: code ?? 1 });
    });

    proc.on("error", () => {
      resolve({ stdout: "", stderr: "", code: 1 });
    });
  });
}
