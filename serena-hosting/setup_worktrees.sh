#!/usr/bin/env bash
# Creates a bare clone of the code history repo and one git worktree per
# {country}-{major} branch, each with a read-only Serena project config.
#
# Usage: setup_worktrees.sh [major] [--index]
#   major    BC major version to host (default: 28)
#   --index  pre-build the Serena symbol index for every branch (slow, optional)
set -euo pipefail

MAJOR="${1:-28}"
INDEX="${2:-}"
DATA_DIR="${SERENA_DATA_DIR:-/data}"
REPO_URL="${SERENA_REPO_URL:-https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History.git}"
BARE="$DATA_DIR/repo.git"
WORKTREES="$DATA_DIR/worktrees"

if [ ! -d "$BARE" ]; then
    git init --bare "$BARE"
    git -C "$BARE" remote add origin "$REPO_URL"
fi

# Only fetch branches of the hosted major to keep the object store small.
git -C "$BARE" config remote.origin.fetch "+refs/heads/*-${MAJOR}:refs/remotes/origin/*-${MAJOR}"
git -C "$BARE" fetch --prune origin

mkdir -p "$WORKTREES"

for ref in $(git -C "$BARE" for-each-ref --format='%(refname:short)' "refs/remotes/origin/*-${MAJOR}"); do
    branch="${ref#origin/}"

    # Skip vNext branches; this host serves released versions only.
    case "$branch" in *-vNext) continue ;; esac

    wt="$WORKTREES/$branch"
    if [ ! -d "$wt" ]; then
        echo "Adding worktree for $branch"
        git -C "$BARE" worktree add --force -B "$branch" "$wt" "$ref"
    fi

    mkdir -p "$wt/.serena"
    cat > "$wt/.serena/project.yml" <<EOF
project_name: "$branch"
language: al
read_only: true
ignore_all_files_in_gitignore: true
EOF

    if [ "$INDEX" = "--index" ]; then
        echo "Indexing $branch"
        serena project index "$wt"
    fi
done

echo "Done. Worktrees in $WORKTREES:"
ls "$WORKTREES"
