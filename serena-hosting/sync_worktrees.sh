#!/usr/bin/env bash
# Syncs all worktrees with the remote. Handles the repo's force-pushed
# history rewrites (late hotfix insertion) via hard reset, and invalidates
# the Serena index cache for branches that changed. Run daily after the
# BuildNewCommits workflow (midnight UTC), e.g. via cron at 04:00 UTC.
#
# Usage: sync_worktrees.sh
set -euo pipefail

DATA_DIR="${SERENA_DATA_DIR:-/data}"
BARE="$DATA_DIR/repo.git"
WORKTREES="$DATA_DIR/worktrees"

git -C "$BARE" fetch --prune origin

for wt in "$WORKTREES"/*/; do
    branch="$(basename "$wt")"

    if ! git -C "$BARE" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
        echo "Branch $branch gone from remote, removing worktree"
        git -C "$BARE" worktree remove --force "$wt"
        continue
    fi

    old="$(git -C "$wt" rev-parse HEAD)"
    new="$(git -C "$BARE" rev-parse "refs/remotes/origin/$branch")"
    if [ "$old" != "$new" ]; then
        echo "Updating $branch ($old -> $new)"
        git -C "$wt" reset --hard "refs/remotes/origin/$branch"
        rm -rf "$wt/.serena/cache"
    fi
done
