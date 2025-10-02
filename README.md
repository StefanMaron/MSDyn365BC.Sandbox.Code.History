# Business Central Code History Repository

This repository holds all versions of the Buisness Central Apps. The purpose is to quickly be able to compare every version to find changes.

There is one separate branch per country-major version.

Go the one of the `w1` branches to find most of the code:  
https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History/branches/all?query=w1

Check out the country specific branches to view the localized base app. For example `DE`:  
https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History/branches/all?query=de

## Schedule

The repository will automatically update itself from the artifacts once a day:

- Regular/current branches will run at midnight UTC and pull the last 24 hours of artifacts
- vNext/insider branches will run at 2 am UTC and pull the last 24 hours of artifacts

## Differences

Main differences between the https://github.com/StefanMaron/MSDyn365BC.Code.History repo:
- Builds on sandbox instead of OnPrem artifacts to include hotfixes
- localization branches only include the localized code, so some of them are empty, some just have the base app (Check w1 branches for all the other code)
- the commits are added by pipelines to reduce runtime
- the pipelines will be scheduled to run daily once the initial load is done.
- there will be branches to cover NextMajor/Minor as well (Look out for suffix vNext in the branches)
- the main branch is just holding the scripts, switch branch to see the BC Code
- Because of the crazy number of versions, I did limit this repo to start with 23.5
- to keep the size of this repo at least in some boundaries, I decided to not include any translation files.

## Partial Clone (Subset of Branches)
To reduce the size of the local clone you can use those commands to clone only the branches you need:

First, clone with those parameters and set it to whatever branch you need:
```
git clone -b w1-24 --single-branch https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History
```
if you want to add additional branches you can do it like this
```
git remote set-branches --add origin de-24
git remote set-branches --add origin de-23
git fetch
```
You can also use wildcards for [remote-branch], e.g.
```
git remote set-branches --add origin us-*
git fetch
```

Removing tracking branches is a little more complicated.
First you need to manually edit the `.git/config` file and remove the branches in the `[remote "origin"]` section
```
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
[remote "origin"]
	url = https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History
	fetch = +refs/heads/w1-23:refs/remotes/origin/w1-23
	fetch = +refs/heads/de-24:refs/remotes/origin/de-24
	fetch = +refs/heads/us-*:refs/remotes/origin/us-*
[branch "w1-23"]
	remote = origin
	merge = refs/heads/w1-23
```
once thats done you need to delete the local reference of the remote branches like this
```
git branch -d -r origin/us-23
git branch -d -r origin/us-24
```
if you had one of those branches checked out locally (a local copy of the branch) you want to delete those as well
```
git branch -D us-23
git branch -D us-24
```

and thats it, now `git fetch` should not pull the branches anymore

## Partial Clone (Shallow Clone)
To further reduce the size of your local repository, you can also utilize the `--depth` parameter with the `git clone` command.
This creates a shallow clone, fetching only the most recent commits up to the specified depth, thereby ignoring the entire history that you might not need.

For instance, to clone only the latest commit (depth of 1), you would use the following command:

```
git clone -b w1-24 --depth 1 https://github.com/StefanMaron/MSDyn365BC.Sandbox.Code.History
```

> [!TIP]
> Using `--depth` implies `--single-branch` unless `--no-single-branch` is given to fetch the histories near the tips of all branches.

Later, you can deepen your clone by 3 commits (or any other number of commits) with `git fetch --deepen 3` or convert it to a complete clone using `git fetch --unshallow`.

## Branch History Rewrites

> [!IMPORTANT]
> Branch history may be rewritten when late hotfixes are released by Microsoft.

**What are late hotfixes?**
Occasionally, Microsoft releases hotfix versions with version numbers lower than already-published versions (e.g., releasing `27.0.40357` after `27.1.40348` is already committed). To maintain semantic version order in git history, the automation uses `git rebase` to insert these hotfixes at the correct chronological position.

**Impact on existing clones:**
- If you have an existing clone and a branch gets rebased, your local copy will become outdated
- `git pull` will fail with "divergent branches" errors

**Solution - Update your local branches automatically:**

Linux/macOS (one-liner):
```bash
curl -sSL https://raw.githubusercontent.com/StefanMaron/MSDyn365BC.Sandbox.Code.History/main/scripts/update-branches.sh | bash
```

Windows (PowerShell):
```powershell
iex (irm https://raw.githubusercontent.com/StefanMaron/MSDyn365BC.Sandbox.Code.History/main/scripts/Update-Branches.ps1)
```

The scripts automatically detect and update all your locally tracked branches. To update specific branches only, add branch names as arguments when running locally.

Or manually for a single branch:
```bash
git fetch origin
git checkout <branch-name>
git reset --hard origin/<branch-name>
```

**Why rewrite history?**
- Maintains correct semantic version order in commit history
- Reduces repository size by avoiding large diffs from out-of-order commits
- Makes version comparison and git blame more intuitive
- This is acceptable for a read-only tracking repository

## Disclaimer

All code is owned by Microsoft. You can not do any pull request on this repository.
