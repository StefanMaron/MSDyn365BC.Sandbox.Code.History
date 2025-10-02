# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is an automated Business Central code history repository that tracks all versions of BC apps from Microsoft. The **main branch contains only automation scripts** - actual BC code is stored in separate branches per country-major version (e.g., `w1-24`, `de-23`).

**Key characteristics:**
- Builds from sandbox artifacts (includes hotfixes, unlike OnPrem artifacts)
- Version range: starts at 23.5.0.0 and newer
- Translation files (*.xlf) are excluded to reduce repository size
- All code is owned by Microsoft (read-only, no PRs accepted)

## Branch Structure

### Naming Convention
- Regular versions: `{country}-{major}` (e.g., `w1-24`, `de-23`)
- Insider/vNext versions: `{country}-{major}-vNext` (e.g., `w1-25-vNext`)

### Country Codes
- `w1`: World-wide version (contains all base code)
- Country-specific branches (e.g., `de`, `us`, `nl`): contain only localized code

**To view BC code, switch to a country-version branch. The main branch only has automation scripts.**

## Automation Architecture

### Workflow Schedule
Two GitHub Actions workflows run daily:
1. **BuildNewCommits.yml** - Regular versions (midnight UTC)
2. **BuildNewCommitsvNext.yml** - Insider versions (2 AM UTC)

### Workflow Process
Both workflows follow this pattern:

1. **Prepare Matrix Job** (`prepare`)
   - Installs BC Container Helper
   - Runs country discovery script (`GetAllCountries.ps1` or `GetAllCountries_vNext.ps1`)
   - Outputs country matrix for parallel processing

2. **Build Commits Job** (`buildCommits`)
   - Matrix strategy processes each country in parallel
   - Runs main automation script (`Auto_load_versions.ps1` or `Auto_load_versions_vNext.ps1`)

### Core Scripts

#### Auto_load_versions.ps1 / Auto_load_versions_vNext.ps1
Main automation scripts with parameter `country` (default: 'w1' for regular, 'de' for vNext).

**Workflow:**
1. Query BC artifacts from last 24 hours using `Get-BCArtifactUrl`
   - Regular: `-Type Sandbox`
   - vNext: `-Type Sandbox -accept_insiderEula -storageAccount bcinsider`
2. Filter versions >= 23.5.0.0
3. For each new version (detected by git log grep):
   - Create or switch to branch `{country}-{major}` or `{country}-{major}-vNext`
   - Branch from previous major's last CU if available, otherwise from main
   - Download artifacts with `Download-Artifacts` (w1 includes platform)
   - Extract to repo using `UpdateALRepo.ps1`
   - Build test workspace with `BuildTestsWorkSpace.ps1`
   - Remove translation files (*.xlf)
   - Commit with message `{country}-{version}` or `{country}-{version}-vNext`
   - Push to origin

#### UpdateALRepo.ps1
Extracts BC application ZIP files into repository structure.

**Parameters:**
- `SourcePath`: Source directory with ZIP files
- `RepoPath`: Target repository path
- `Localization`, `Version`: Metadata parameters

**Process:**
1. Delete all existing directories except `scripts` and `.git`
2. Find all *.zip files recursively in source
3. Extract each ZIP using 7z to maintain folder structure
4. Clean up ZIP filename suffixes (`.Source`, `..Source`)

#### BuildTestsWorkSpace.ps1
Creates VS Code workspace for test apps.

**Process:**
1. Find all directories with `*test*` in name (recursively)
2. Add leaf test directories to workspace folders array
3. Configure workspace settings:
   - Disable allint, code actions, code analysis
   - Exclude *.xlf files from search
4. Output to `test-apps.code-workspace`

#### GetAllCountries.ps1 / GetAllCountries_vNext.ps1
Discovers available country codes from BC artifacts.

**Process:**
1. Query all sandbox artifacts (regular or insider)
2. Extract country code from artifact URL path (position 3)
3. Filter for versions >= 23.5.0.0
4. Output unique country list as GitHub Actions matrix JSON

## Development Commands

### Running Automation Locally

```bash
# Process regular versions for specific country
pwsh ./scripts/Auto_load_versions.ps1 -country w1

# Process insider versions
pwsh ./scripts/Auto_load_versions_vNext.ps1 -country de

# Get list of available countries
pwsh ./scripts/GetAllCountries.ps1
pwsh ./scripts/GetAllCountries_vNext.ps1
```

### Artifact Management

**Requirements:**
- BC Container Helper PowerShell module (`Install-Module bccontainerhelper -force`)
- 7zip for extraction (`7z` command)

**Artifact locations:**
- Regular: Default BC artifacts storage
- Insider: `bcinsider` storage account with `-accept_insiderEula`

### Git Operations

**Partial clone for specific branches:**
```bash
# Clone single branch
git clone -b w1-24 --single-branch https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History

# Add more branches
git remote set-branches --add origin de-24
git remote set-branches --add origin us-*
git fetch

# Shallow clone (recent commits only)
git clone -b w1-24 --depth 1 https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History
```

**Deepen shallow clone:**
```bash
git fetch --deepen 3      # Deepen by 3 commits
git fetch --unshallow     # Convert to complete clone
```

## Technical Details

### Version Detection
New versions are detected by checking git log for commit messages matching the exact pattern `{country}-{version}` or `{country}-{version}-vNext`. If no commit exists, the version is processed.

### Branch Creation Logic
- If branch exists: switch to it
- If new branch:
  - Major version > 15 and Build > 5: branch from previous major's .5 CU
  - Otherwise: branch from main branch's latest commit

### Late Hotfix Handling
When Microsoft releases hotfixes later in time (after newer versions have been committed), the automation detects and handles them via retroactive insertion to minimize repository bloat:

**Detection:**
- Compares incoming version against current branch HEAD
- If incoming version < HEAD version, triggers late hotfix workflow

**Insertion Process:**
1. Parses all existing versions on the branch to find correct chronological position
2. Finds insertion point: the highest version commit that's still lower than the hotfix version
3. Checks out the insertion point commit
4. Extracts and commits the hotfix at that point
5. Rebases all subsequent commits onto the new hotfix commit
6. Force pushes with `--force-with-lease` to update remote branch

**Benefits:**
- Maintains semantic version order in Git history
- Avoids massive diffs from chronological-only commits
- Significantly reduces repository size
- Git history accurately reflects version progression

**Trade-offs:**
- Rewrites branch history (acceptable for read-only tracking repo)
- Existing clones become outdated and need re-cloning
- Uses `--force-with-lease` for safe force-push operations

### Artifact Path Resolution
The script handles two folder structures:
1. **Localization folder**: `Applications.{COUNTRY}` (e.g., `Applications.DE`)
2. **Platform folder**: `Applications` (fallback for w1 or when localization not found)

### File Exclusions
- Translation files (*.xlf) are automatically removed after extraction
- This significantly reduces repository size while preserving code history
