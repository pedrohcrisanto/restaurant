#!/usr/bin/env bash
set -euo pipefail

# Simple local runner to execute `make test-save` on demand.
# Usage: run once in a terminal: `make agent-watch`
# It will run the suite immediately, then watch for a trigger file at tmp/agent/trigger.

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

mkdir -p tmp tmp/agent

run_tests() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running test suite (make test-save)..."
  # Never fail the loop; we just want the output saved to tmp/rspec_output.txt
  make test-save || true
  date '+%Y-%m-%d %H:%M:%S' > tmp/agent/last_run
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Test run finished. Output at tmp/rspec_output.txt"
}

# First run immediately
run_tests

echo "Watching for trigger at tmp/agent/trigger (CTRL+C to stop)"
while true; do
  if [[ -f tmp/agent/trigger ]]; then
    rm -f tmp/agent/trigger
    run_tests
  fi
  sleep 2
done

