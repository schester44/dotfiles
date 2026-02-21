#!/usr/bin/env node

import { spawn, execSync } from "node:child_process";

const useProfile = process.argv[2] === "--profile";

if (process.argv[2] && process.argv[2] !== "--profile") {
  console.log("Usage: start.ts [--profile]");
  console.log("\nOptions:");
  console.log(
    "  --profile  Copy your default Chrome profile (cookies, logins)",
  );
  console.log("\nExamples:");
  console.log("  start.ts            # Start with fresh profile");
  console.log("  start.ts --profile  # Start with your Chrome profile");
  process.exit(1);
}

// Check if debuggable Chrome is already running on port 9222
let alreadyRunning = false;
try {
  const response = await fetch("http://localhost:9222/json/version");
  if (response.ok) {
    alreadyRunning = true;
  }
} catch {}

if (alreadyRunning) {
  console.log("✓ Chrome already running on :9222");
  process.exit(0);
}

// Setup profile directory
execSync("mkdir -p ~/.cache/scraping", { stdio: "ignore" });

// Determine which profile directory to use
let profileDir = "Default";
if (useProfile) {
  // Check Local State for available profiles and pick the most recently active one
  try {
    const localState = JSON.parse(
      execSync(`cat "${process.env["HOME"]}/Library/Application Support/Google/Chrome/Local State"`, { encoding: "utf-8" })
    );
    const profiles = localState?.profile?.info_cache || {};
    let bestProfile = null;
    let bestTime = 0;
    for (const [name, info] of Object.entries(profiles)) {
      if (info.active_time > bestTime && !name.includes("Guest") && !name.includes("System")) {
        bestTime = info.active_time;
        bestProfile = name;
      }
    }
    if (bestProfile) {
      profileDir = bestProfile;
    }
  } catch {}

  // Sync profile with rsync (much faster on subsequent runs)
  // Exclude lock files and other files that would conflict
  execSync(
    `rsync -a --delete \
      --exclude='SingletonLock' \
      --exclude='SingletonSocket' \
      --exclude='SingletonCookie' \
      --exclude='lockfile' \
      --exclude='*.lock' \
      "${process.env["HOME"]}/Library/Application Support/Google/Chrome/" ~/.cache/scraping/`,
    { stdio: "pipe" },
  );
}

// Start Chrome in background (detached so Node can exit)
// Using a separate user-data-dir allows this to run alongside existing Chrome
spawn(
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
  [
    "--remote-debugging-port=9222",
    `--user-data-dir=${process.env["HOME"]}/.cache/scraping`,
    `--profile-directory=${profileDir}`,
    "--disable-search-engine-choice-screen",
    "--no-first-run",
    "--disable-features=ProfilePicker",
  ],
  { detached: true, stdio: "ignore" },
).unref();

// Wait for Chrome to be ready by checking the debugging endpoint
let connected = false;
for (let i = 0; i < 30; i++) {
  try {
    const response = await fetch("http://localhost:9222/json/version");
    if (response.ok) {
      connected = true;
      break;
    }
  } catch {
    await new Promise((r) => setTimeout(r, 500));
  }
}

if (!connected) {
  console.error("✗ Failed to connect to Chrome");
  process.exit(1);
}

console.log(
  `✓ Chrome started on :9222${useProfile ? " with your profile" : ""}`,
);
