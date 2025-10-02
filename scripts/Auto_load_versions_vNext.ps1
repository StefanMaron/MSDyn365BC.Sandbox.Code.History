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
            git commit -a -m "$($country)-$($version.ToString())-vNext" | out-null

            # Get the hash of the new commit
            $NewCommitHash = git rev-parse HEAD

            # Switch back to branch
            git switch "$($country)-$($Version.Major)-vNext"

            # Rebase all commits after insertion point onto the new commit
            Write-Host "Rebasing commits after insertion point onto new commit..."
            $RebaseResult = git rebase --onto $NewCommitHash $InsertionPoint "$($country)-$($Version.Major)-vNext" 2>&1

            if ($LASTEXITCODE -ne 0) {
                Write-Host "Rebase failed, aborting..."
                git rebase --abort
                throw "Rebase failed: $RebaseResult"
            }

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
            git commit -a -m "$($country)-$($version.ToString())-vNext" | out-null
            git gc | out-null
            git push --set-upstream origin "$($country)-$($Version.Major)-vNext"
        }
        
        Flush-ContainerHelperCache -keepDays 0 -ErrorAction SilentlyContinue

        Write-Host "$($country)-$($version.ToString())-vNext"
    }
    else {
        Write-Host "###############################################"
        Write-Host "Skipped version $($country) - $($version.ToString()) - vNext"
        Write-Host "###############################################"
    }
}

 
