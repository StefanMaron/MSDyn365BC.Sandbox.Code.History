#!/usr/bin/env bash
set -euo pipefail

cmd="${1:-serve}"
shift || true

case "$cmd" in
    serve) exec python /app/orchestrator.py ;;
    setup) exec /app/setup_worktrees.sh "$@" ;;
    sync)  exec /app/sync_worktrees.sh "$@" ;;
    *)     echo "Usage: entrypoint.sh {serve|setup|sync} [args]" >&2; exit 1 ;;
esac
