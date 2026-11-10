import { execFileSync } from "node:child_process";

execFileSync(
  "bun",
  ["test", "packages/cloud/services/redis-rest/cloudflare/bridge.test.ts"],
  {
    stdio: "inherit",
    timeout: 30000,
  },
);
