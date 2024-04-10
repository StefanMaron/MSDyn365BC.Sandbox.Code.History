# Business Central Code History Repository

This repository holds all versions of the Buisness Central Apps. The purpose is to quickly be able to compare every version to find changes.

There is one separate branch per country-major version.

Main differences between the https://github.com/StefanMaron/MSDyn365BC.Code.History repo:
- Builds on sandbox instead of OnPrem artifacts to include hotfixes
- localization branches only include the localized code, so some of them are empty, some just have the base app (Check w1 branches for all the other code)
- the commits are added by pipelines to reduce runtime
- the pipelines will be scheduled to run daily once the initial load is done.
- there will be branches to cover NextMajor/Minor as well (Look out for suffix vNext in the branches)
- the main branch is just holding the scripts, switch branch to see the BC Code
- Because of the crazy number of versions, I did limit this repo to start with 23.5
- to keep the size of this repo at least in some boundaries, I decided to not include any translation files.

to reduce the size of the local clone you can use those commands to clone only the branches you need:

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
and thats it, now `git fetch` should not pull the branches anymore

## Disclaimer

All code is owned by Microsoft. You can not do any pull request on this repository.
