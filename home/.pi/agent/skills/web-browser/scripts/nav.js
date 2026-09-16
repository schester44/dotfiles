#!/usr/bin/env node

import { call } from "./client.js";

const url = process.argv[2];
const flags = process.argv.slice(3);
const newTab = flags.includes("--new");
const idle = flags.includes("--idle");

if (!url) {
  console.log("Usage: nav.js <url> [--new] [--idle]");
  console.log("\nExamples:");
  console.log("  nav.js https://example.com        # Navigate current tab (waits for load)");
  console.log("  nav.js https://example.com --new  # Open in new tab");
  console.log("  nav.js https://example.com --idle # Wait for network idle (SPAs, late banners)");
  process.exit(1);
}

try {
  const result = await call("nav", { url, newTab, wait: idle ? "idle" : "load" });
  const status = result.loaded === false ? " (wait condition not met within 15s)" : "";
  console.log(newTab ? "✓ Opened:" : "✓ Navigated to:", url, status);
} catch (e) {
  console.error("✗", e.message);
  process.exit(1);
}
