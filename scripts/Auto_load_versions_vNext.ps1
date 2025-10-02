param (
    [string]$country = 'de'
)

$ErrorActionPreference = "SilentlyContinue"

[System.Collections.ArrayList]$Versions = @()
Get-BCArtifactUrl -select All -Type Sandbox -country $country -accept_insiderEula -storageAccount bcinsider -after ([DateTime]::Today.AddDays(-1)) | % {
    [System.Uri]$Url = $_
    $TempString = $Url.AbsolutePath
    [version]$Version = $TempString.Split('/')[2]
    $country = $TempString.Split('/')[3]

    [hashtable]$objectProperty = @{}
    $objectProperty.Add('Version', $Version)
    $objectProperty.Add('Country', $country)
    $objectProperty.Add('URL', $Url)
    $ourObject = New-Object -TypeName psobject -Property $objectProperty

    if ($Version -ge [version]::Parse('23.5.0.0')) {
        $Versions.Add($ourObject)
    }
}

$Versions | Sort-Object -Property Country, Version | % {
    [version]$Version = $_.Version
    $country = $_.Country.Trim()

    Write-Host ($($country)-$($version.ToString()))

    # Defensive check: clean up any stuck rebase state before processing
    $RebaseMergeDir = Join-Path (Get-Location) ".git/rebase-merge"
    $RebaseApplyDir = Join-Path (Get-Location) ".git/rebase-apply"
    if ((Test-Path $RebaseMergeDir) -or (Test-Path $RebaseApplyDir)) {
        Write-Host "WARNING: Detected stuck rebase state, cleaning up..."
        git rebase --abort 2>&1 | Out-Null
        git rebase --quit 2>&1 | Out-Null
        # Force remove directories if git commands failed
        if (Test-Path $RebaseMergeDir) { Remove-Item -Recurse -Force $RebaseMergeDir }
        if (Test-Path $RebaseApplyDir) { Remove-Item -Recurse -Force $RebaseApplyDir }
    }

    git fetch --all

    # $RegularBranchExists = git ls-remote --heads origin "refs/heads/$($country)-$($version.Major)"
    # $CommitDoesExist =  git log --all -n 1 --grep="$($country)-$($version.Major).$($version.Minor).[0-9]*.[0-9]*$"

    # if ($RegularBranchExists -and $CommitDoesExist) { 
    #     git push -d origin "$($country)-$($Version.Major)-vNext"
    #     git branch -d "$($country)-$($Version.Major)-vNext"
    #     return
    # }

    $LastCommit = git log --all --grep="^$($country)-$($version.ToString())-vNext"

    if ($LastCommit.Length -eq 0) {
        Write-Host "###############################################"
        Write-Host "Processing $($country) - $($Version.ToString()) - vNext"
        Write-Host "###############################################"

        $LatestCommitIDOfBranchEmpty = git log -n 1 --pretty=format:"%h" "main"
        if ($LatestCommitIDOfBranchEmpty -eq $null) {
            $LatestCommitIDOfBranchEmpty = git log -n 1 --pretty=format:"%h" "origin/main"
        }

        $CommitIDLastCUFromPreviousMajor = $null

        if ($Version.Major -gt 15 -and $Version.Minor -eq 0) {
            $CommitIDLastCUFromPreviousMajor = git log --all -n 1 --grep="^$($country)-$($version.Major - 1).5" --pretty=format:"%h"
            if (!$CommitIDLastCUFromPreviousMajor) {
                $CommitIDLastCUFromPreviousMajor = git log --all -n 1 --grep="^$($country)-$($version.Major - 1).[0-9]*.[0-9]*.[0-9]*$" --pretty=format:"%h"
            }
        }
        elseif ($Version.Major -gt 15 -and $Version.Minor -gt 5) {
            $CommitIDLastCUFromPreviousMajor = git log --all -n 1 --grep="^$($country)-$($version.Major).5" --pretty=format:"%h"
        }
        elseif ($Version.Major -gt 15 -and $Version.Minor -lt 5) {
            $CommitIDLastCUFromPreviousMajor = git log --all -n 1 --grep="^$($country)-$($version.Major)" --pretty=format:"%h"
        }
        else {
            $CommitIDLastCUFromPreviousMajor = $null
        }

        $BranchAlreadyExists = ((git branch --list -r "origin/$($country)-$($Version.Major)-vNext") -ne $null) -or ((git branch --list "$($country)-$($Version.Major)-vNext") -ne $null)

        if ($BranchAlreadyExists) {
            git switch "$($country)-$($Version.Major)-vNext"
        }
        else {
            if ($CommitIDLastCUFromPreviousMajor -ne $null) {
                git switch -c "$($country)-$($Version.Major)-vNext" $CommitIDLastCUFromPreviousMajor
            }
            else {
                git switch -c "$($country)-$($Version.Major)-vNext" $LatestCommitIDOfBranchEmpty
            }
        }

        # Check if this is a late hotfix (older than current HEAD)
        $IsLateHotfix = $false
        $InsertionPoint = $null

        if ($BranchAlreadyExists) {
            # Get the latest version on this branch
            $LatestVersionCommit = git log -n 1 --pretty=format:"%s" "$($country)-$($Version.Major)-vNext"
            if ($LatestVersionCommit -match "^$($country)-(.+)-vNext$") {
                $LatestVersion = [version]::Parse($Matches[1])

                if ($Version -lt $LatestVersion) {
                    Write-Host "Detected late hotfix: $($Version) is older than current HEAD $($LatestVersion)"
                    $IsLateHotfix = $true

                    # Find all versions on this branch to determine insertion point
                    $AllVersionsOnBranch = git log --pretty=format:"%s" "$($country)-$($Version.Major)-vNext" | Where-Object { $_ -match "^$($country)-(.+)-vNext$" } | ForEach-Object {
                        [PSCustomObject]@{
                            CommitMessage = $_
                            Version = [version]::Parse($Matches[1])
                        }
                    }

                    # Find the commit this should come after (highest version that's still lower than new version)
                    $PreviousVersion = $AllVersionsOnBranch | Where-Object { $_.Version -lt $Version } | Sort-Object -Property Version -Descending | Select-Object -First 1

                    if ($PreviousVersion) {
                        $InsertionPoint = git log -n 1 --pretty=format:"%H" --grep="^$($PreviousVersion.CommitMessage)$" "$($country)-$($Version.Major)-vNext"
                        Write-Host "Will insert after version $($PreviousVersion.Version) (commit: $InsertionPoint)"
                    }
                    else {
                        # No previous version found, insert at branch start
                        $InsertionPoint = git log --reverse --pretty=format:"%H" "$($country)-$($Version.Major)-vNext" | Select-Object -First 1
                        Write-Host "Will insert at beginning of branch (commit: $InsertionPoint)"
                    }
                }
            }
        }
        
        if ($country -eq 'w1'){
            $Paths = Download-Artifacts -artifactUrl $_.URL -includePlatform
            $LocalizationPath = $Paths[0]
            $PlatformPath = $Paths[1]
        }
        else {
            $Paths = Download-Artifacts -artifactUrl $_.URL
            $LocalizationPath = $Paths
            $PlatformPath = ''
        }

        #Localization folder        
        $TargetPathOfVersion = (Join-Path $LocalizationPath (Get-ChildItem -Path $LocalizationPath -filter "Applications.$($country.ToUpper())")[0].Name)

        if (-not (Test-Path $TargetPathOfVersion)) {
            #Platform Folder
            $TargetPathOfVersion = (Join-Path $PlatformPath (Get-ChildItem -Path $PlatformPath -filter "Applications")[0].Name)
        }
        
        if ($IsLateHotfix) {
            # Checkout the insertion point
            git checkout $InsertionPoint

            # Extract and commit the hotfix
            & "scripts/UpdateALRepo.ps1" -SourcePath $TargetPathOfVersion -RepoPath (Split-Path $PSScriptRoot -Parent) -Version $version -Localization $country
            & "scripts/BuildTestsWorkSpace.ps1"

            Get-ChildItem -Recurse -Filter "*.xlf" | Remove-Item

            "$($country)-$($version.ToString())" > version.txt

            git config user.email "stefanmaron@outlook.de"
            git config user.name "Stefan Maron"
            git add -A | out-null
            git commit -a -m "$($country)-$($version.ToString())" | out-null

            # Get the hash of the new commit
            $NewCommitHash = git rev-parse HEAD

            # Switch back to branch
            git switch "$($country)-$($Version.Major)-vNext"

            # Rebase all commits after insertion point onto the new commit
            # Use -X ours strategy to auto-resolve conflicts by keeping the version being rebased
            Write-Host "Rebasing commits after insertion point onto new commit..."
            $RebaseResult = git rebase -X ours --onto $NewCommitHash $InsertionPoint "$($country)-$($Version.Major)-vNext" 2>&1

            if ($LASTEXITCODE -ne 0) {
                Write-Host "##[warning]Rebase with auto-merge failed, attempting manual conflict resolution..."

                # Get conflicted files
                $ConflictedFiles = git diff --name-only --diff-filter=U 2>&1

                if ($ConflictedFiles) {
                    Write-Host "Conflicted files: $($ConflictedFiles -join ', ')"

                    # For metadata files, use --ours (keep the commit being rebased)
                    foreach ($file in $ConflictedFiles) {
                        if ($file -match "app\.json$" -or $file -match "AppSourceCop\.json$" -or $file -eq "version.txt") {
                            Write-Host "Auto-resolving $file (keeping rebased commit's version)"
                            git checkout --ours $file 2>&1 | Out-Null
                            git add $file 2>&1 | Out-Null
                        }
                        else {
                            Write-Host "##[error]Unexpected conflict in non-metadata file: $file"
                        }
                    }

                    # Try to continue rebase
                    Write-Host "Continuing rebase after conflict resolution..."
                    $ContinueResult = git -c core.editor=true rebase --continue 2>&1

                    # Keep resolving conflicts until rebase completes
                    while ($LASTEXITCODE -ne 0 -and $ContinueResult -match "git rebase --continue") {
                        $ConflictedFiles = git diff --name-only --diff-filter=U 2>&1
                        if ($ConflictedFiles) {
                            foreach ($file in $ConflictedFiles) {
                                if ($file -match "app\.json$" -or $file -match "AppSourceCop\.json$" -or $file -eq "version.txt") {
                                    git checkout --ours $file 2>&1 | Out-Null
                                    git add $file 2>&1 | Out-Null
                                }
                            }
                            $ContinueResult = git -c core.editor=true rebase --continue 2>&1
                        }
                        else {
                            break
                        }
                    }
                }

                if ($LASTEXITCODE -ne 0) {
                    Write-Host "##[error]Rebase failed for late hotfix $($country)-$($Version.ToString())-vNext"
                    Write-Host "Rebase output: $RebaseResult"

                    # Clean up rebase state
                    git rebase --abort 2>&1 | Out-Null
                    git rebase --quit 2>&1 | Out-Null

                    # Force cleanup directories if commands failed
                    $RebaseMergeDir = Join-Path (Get-Location) ".git/rebase-merge"
                    $RebaseApplyDir = Join-Path (Get-Location) ".git/rebase-apply"
                    if (Test-Path $RebaseMergeDir) { Remove-Item -Recurse -Force $RebaseMergeDir }
                    if (Test-Path $RebaseApplyDir) { Remove-Item -Recurse -Force $RebaseApplyDir }

                    # Use exit instead of throw to bypass SilentlyContinue
                    Write-Host "##[error]Exiting due to rebase failure"
                    exit 1
                }
            }

            Write-Host "Rebase completed successfully"
            git gc | out-null

            # Force push with lease to prevent overwriting concurrent changes
            Write-Host "Force pushing rebased history..."
            git push --force-with-lease origin "$($country)-$($Version.Major)-vNext"
        }
        else {
            # Normal linear commit (not a late hotfix)
            & "scripts/UpdateALRepo.ps1" -SourcePath $TargetPathOfVersion -RepoPath (Split-Path $PSScriptRoot -Parent) -Version $version -Localization $country
            & "scripts/BuildTestsWorkSpace.ps1"

            Get-ChildItem -Recurse -Filter "*.xlf" | Remove-Item

            "$($country)-$($version.ToString())" > version.txt

            git config user.email "stefanmaron@outlook.de"
            git config user.name "Stefan Maron"
            git add -A | out-null
            git commit -a -m "$($country)-$($version.ToString())" | out-null
            git gc | out-null

            # Pull with rebase to handle concurrent updates (e.g., late hotfixes)
            git pull --rebase origin "$($country)-$($Version.Major)-vNext" 2>&1 | Out-Null

            git push --set-upstream origin "$($country)-$($Version.Major)-vNext"
        }
        
        Flush-ContainerHelperCache -keepDays 0 -ErrorAction SilentlyContinue

        Write-Host "$($country)-$($version.ToString())"
    }
    else {
        Write-Host "###############################################"
        Write-Host "Skipped version $($country) - $($version.ToString()) - vNext"
        Write-Host "###############################################"
    }
}

 
