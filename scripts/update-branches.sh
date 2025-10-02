#!/bin/bash

#
# Updates local branches after history rewrites from late hotfix rebases.
#
# Usage:
#   ./update-branches.sh [branch1] [branch2] ...
#   ./update-branches.sh w1-24 w1-25 de-24
#   ./update-branches.sh --dry-run
#   ./update-branches.sh (updates all tracked branches)
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse arguments
DRY_RUN=false
BRANCHES=()

for arg in "$@"; do
    if [ "$arg" == "--dry-run" ] || [ "$arg" == "-n" ]; then
        DRY_RUN=true
    else
        BRANCHES+=("$arg")
    fi
done

# Ensure we're in a git repository
if [ ! -d .git ]; then
    echo -e "${RED}Error: This script must be run from the root of the git repository${NC}"
    exit 1
fi

echo -e "${CYAN}Fetching latest changes from origin...${NC}"
git fetch --all --prune || {
    echo -e "${RED}Failed to fetch from origin${NC}"
    exit 1
}

# Determine which branches to update
BRANCHES_TO_UPDATE=()

if [ ${#BRANCHES[@]} -eq 0 ]; then
    # Get all remote tracking branches
    echo -e "${YELLOW}No branches specified, updating all locally tracked remote branches...${NC}"
    while IFS= read -r line; do
        # Extract branch name from git branch -vv output
        if [[ $line =~ ^[[:space:]]*\*?[[:space:]]+([^[:space:]]+)[[:space:]]+.* ]]; then
            branch="${BASH_REMATCH[1]}"
            # Only include if it tracks a remote branch
            if [[ $line =~ \[origin/ ]]; then
                BRANCHES_TO_UPDATE+=("$branch")
            fi
        fi
    done < <(git branch -vv)
else
    # Expand wildcards in branch patterns
    for pattern in "${BRANCHES[@]}"; do
        found=false
        while IFS= read -r remote_branch; do
            # Extract branch name (remove origin/ prefix and trim spaces)
            branch=$(echo "$remote_branch" | sed 's/^[[:space:]]*origin\///' | sed 's/^refs\/heads\///')

            # Check if matches pattern (simple wildcard support)
            if [[ "$branch" == $pattern ]]; then
                BRANCHES_TO_UPDATE+=("$branch")
                found=true
            fi
        done < <(git branch -r | grep -E "^[[:space:]]*origin/$pattern\$" || true)

        if [ "$found" == false ]; then
            echo -e "${YELLOW}Warning: No branches found matching pattern: $pattern${NC}"
        fi
    done
fi

if [ ${#BRANCHES_TO_UPDATE[@]} -eq 0 ]; then
    echo -e "${YELLOW}No branches to update${NC}"
    exit 0
fi

echo ""
echo -e "${CYAN}Branches to update:${NC}"
for branch in "${BRANCHES_TO_UPDATE[@]}"; do
    echo "  - $branch"
done

if [ "$DRY_RUN" == true ]; then
    echo ""
    echo -e "${YELLOW}[DRY RUN] No changes were made.${NC}"
    exit 0
fi

echo ""

# Save current branch
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "HEAD")

# Update each branch
for branch in "${BRANCHES_TO_UPDATE[@]}"; do
    echo -e "${GREEN}Updating branch: $branch${NC}"

    # Check if remote branch exists
    if ! git ls-remote --heads origin "refs/heads/$branch" | grep -q "$branch"; then
        echo -e "${YELLOW}  Remote branch 'origin/$branch' does not exist, skipping${NC}"
        continue
    fi

    # Check if local branch exists
    if git rev-parse --verify --quiet "$branch" >/dev/null 2>&1; then
        # Branch exists locally, reset it
        if ! git checkout "$branch" 2>/dev/null; then
            echo -e "${YELLOW}  Failed to checkout branch $branch, skipping${NC}"
            continue
        fi

        # Check if branch has diverged
        if ! git merge-base --is-ancestor "origin/$branch" HEAD 2>/dev/null; then
            echo -e "${YELLOW}  Branch has diverged, resetting to origin/$branch${NC}"
        fi

        git reset --hard "origin/$branch" >/dev/null
        echo -e "${GREEN}  ✓ Updated $branch to match origin${NC}"
    else
        # Branch doesn't exist locally, create it
        if git checkout -b "$branch" "origin/$branch" 2>/dev/null; then
            echo -e "${GREEN}  ✓ Created local branch $branch from origin${NC}"
        else
            echo -e "${YELLOW}  Failed to create branch $branch${NC}"
        fi
    fi
done

# Return to original branch if it still exists
if [ "$current_branch" != "HEAD" ]; then
    git checkout "$current_branch" 2>/dev/null || true
    echo ""
    echo -e "${CYAN}Returned to branch: $current_branch${NC}"
fi

echo ""
echo -e "${GREEN}✓ Branch update complete!${NC}"
