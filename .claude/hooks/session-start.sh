#!/bin/bash
set -euo pipefail

# Start OpenViking MCP server if not already running
if curl -sf http://localhost:1933/health > /dev/null 2>&1; then
  echo "OpenViking server already running on :1933"
  exit 0
fi

echo "Starting OpenViking server..."
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
python "$REPO_DIR/openviking_cli/server_bootstrap.py" >> /tmp/openviking-server.log 2>&1 &

# Wait up to 10s for it to be ready
for i in $(seq 1 10); do
  if curl -sf http://localhost:1933/health > /dev/null 2>&1; then
    echo "OpenViking server ready on :1933"
    exit 0
  fi
  sleep 1
done

echo "Warning: OpenViking server did not become ready in time. Check /tmp/openviking-server.log"
exit 0
