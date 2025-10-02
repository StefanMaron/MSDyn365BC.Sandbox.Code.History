#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Updates local branches after history rewrites from late hotfix rebases.

.DESCRIPTION
    This script safely updates local branches that may have been rebased on the remote.
    It fetches the latest changes and resets each specified branch to match the remote.

.PARAMETER branches
    Array of branch names to update (e.g., "w1-24", "de-25-vNext").
    If not specified, updates all locally tracked remote branches.

.PARAMETER DryRun
    Show what would be updated without making changes.

.EXAMPLE
    .\Update-Branches.ps1 -branches w1-24,w1-25,de-24

.EXAMPLE
    .\Update-Branches.ps1 -branches w1-*

.EXAMPLE
    .\Update-Branches.ps1
    Updates all tracked branches.

.EXAMPLE
    .\Update-Branches.ps1 -DryRun
    Shows what would be updated without making changes.
#>

param (
    [Parameter(Position = 0)]
    [string[]]$branches,

    [switch]$DryRun
)

# Ensure we're in a git repository
if (-not (Test-Path .git)) {
    Write-Error "This script must be run from the root of the git repository"
    exit 1
}

Write-Host "Fetching latest changes from origin..." -ForegroundColor Cyan
git fetch --all --prune

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to fetch from origin"
    exit 1
}

# Determine which branches to update
if ($branches) {
    $branchesToUpdate = @()
    foreach ($pattern in $branches) {
        # Expand wildcards - use exact match with line boundaries
        $matchedBranches = git branch -r | Where-Object { $_.Trim() -match "^origin/$pattern$" } | ForEach-Object { $_.Trim() -replace '^origin/', '' }
        if ($matchedBranches) {
            $branchesToUpdate += $matchedBranches
        }
        else {
            Write-Warning "No branches found matching pattern: $pattern"
        }
    }
}
else {
    # Get all remote tracking branches
    Write-Host "No branches specified, updating all locally tracked remote branches..." -ForegroundColor Yellow
    $branchesToUpdate = git branch -vv | Where-Object { $_ -match '\[origin/' } | ForEach-Object {
        if ($_ -match '^\*?\s+(\S+)') {
            $Matches[1]
        }
    }
}

if ($branchesToUpdate.Count -eq 0) {
    Write-Warning "No branches to update"
    exit 0
}

Write-Host "`nBranches to update:" -ForegroundColor Cyan
$branchesToUpdate | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }

if ($DryRun) {
    Write-Host "`n[DRY RUN] No changes were made." -ForegroundColor Yellow
    exit 0
}

Write-Host ""

$currentBranch = git rev-parse --abbrev-ref HEAD

foreach ($branch in $branchesToUpdate) {
    Write-Host "Updating branch: $branch" -ForegroundColor Green

    # Check if remote branch exists
    $remoteBranchExists = git ls-remote --heads origin "refs/heads/$branch" 2>$null
    if (-not $remoteBranchExists) {
        Write-Warning "  Remote branch 'origin/$branch' does not exist, skipping"
        continue
    }

    # Check if local branch exists
    $localBranchExists = git rev-parse --verify --quiet $branch

    if ($localBranchExists) {
        # Branch exists locally, reset it
        git checkout $branch 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "  Failed to checkout branch $branch, skipping"
            continue
        }

        # Check if branch has diverged
        git merge-base --is-ancestor origin/$branch HEAD 2>&1 | Out-Null
        $isAncestor = $LASTEXITCODE -eq 0

        if (-not $isAncestor) {
            Write-Host "  Branch has diverged, resetting to origin/$branch" -ForegroundColor Yellow
        }

        git reset --hard origin/$branch | Out-Null
        Write-Host "  ✓ Updated $branch to match origin" -ForegroundColor Green
    }
    else {
        # Branch doesn't exist locally, create it
        git checkout -b $branch origin/$branch 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Created local branch $branch from origin" -ForegroundColor Green
        }
        else {
            Write-Warning "  Failed to create branch $branch"
        }
    }
}

# Return to original branch if it still exists
if ($currentBranch -ne "HEAD") {
    git checkout $currentBranch 2>&1 | Out-Null
    Write-Host "`nReturned to branch: $currentBranch" -ForegroundColor Cyan
}

Write-Host "`n✓ Branch update complete!" -ForegroundColor Green
