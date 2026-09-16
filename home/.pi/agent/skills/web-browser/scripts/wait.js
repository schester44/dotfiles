#!/usr/bin/env node

import { call } from "./client.js";

const args = process.argv.slice(2);
const usage = () => {
  console.log("Usage: wait.js <css-selector> [timeoutMs]");
  console.log("       wait.js --gone <css-selector> [timeoutMs]");
  console.log("       wait.js --js '<expression>' [timeoutMs]");
  console.log("\nResolves the instant the condition is met (MutationObserver, no polling).");
  console.log("\nExamples:");
  console.log("  wait.js '#search-results'            # element appears");
  console.log("  wait.js --gone '.loading-spinner'    # element disappears");
  console.log("  wait.js --js 'document.title.includes(\"Order\")' 30000");
  process.exit(1);
};

if (args.length === 0) usage();

let params = {};
if (args[0] === "--gone") {
  if (!args[1]) usage();
  params = { gone: args[1], timeout: Number(args[2]) || 15000 };
} else if (args[0] === "--js") {
  if (!args[1]) usage();
  params = { js: args[1], timeout: Number(args[2]) || 15000 };
} else {
  params = { selector: args[0], timeout: Number(args[1]) || 15000 };
}

try {
  await call("waitFor", params, params.timeout + 5000);
  console.log("✓ Condition met");
} catch (e) {
  console.error("✗", e.message);
  process.exit(1);
}
