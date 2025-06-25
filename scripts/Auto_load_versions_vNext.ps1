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
        
        & "scripts/UpdateALRepo.ps1" -SourcePath $TargetPathOfVersion -RepoPath (Split-Path $PSScriptRoot -Parent) -Version $version -Localization $country
        & "scripts/BuildTestsWorkSpace.ps1"
        
        Get-ChildItem -Recurse -Filter "*.xlf" | Remove-Item

        "$($country)-$($version.ToString())" > version.txt

        git config user.email "stefanmaron@outlook.de"
        git config user.name "Stefan Maron"
        git add -A | out-null
        git commit -a -m "$($country)-$($version.ToString())-vNext" | out-null
        git gc | out-null
        git pull origin
        git push --set-upstream origin "$($country)-$($Version.Major)-vNext"
        
        Flush-ContainerHelperCache -keepDays 0 -ErrorAction SilentlyContinue

        Write-Host "$($country)-$($version.ToString())-vNext"
    }
    else {
        Write-Host "###############################################"
        Write-Host "Skipped version $($country) - $($version.ToString()) - vNext"
        Write-Host "###############################################"
    }
}

 
