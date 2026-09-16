#!/usr/bin/env node

import { call } from "./client.js";

try {
  const filepath = await call("screenshot", {}, 15000);
  console.log(filepath);
} catch (e) {
  console.error("✗", e.message);
  process.exit(1);
}
