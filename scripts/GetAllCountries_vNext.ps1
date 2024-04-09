$countries = [System.Collections.ArrayList]::new()
Get-BCArtifactUrl -select All -Type Sandbox -accept_insiderEula -storageAccount bcinsider | % {
    [System.Uri]$Url = $_
    [version]$Version = $Url.AbsolutePath.Split('/')[2]
    if ($Version -ge [version]::Parse('23.5.0.0')) {
        $Url.AbsolutePath.Split('/')[3]
    } 
}| Sort-object -unique | % { $countries.Add($_)}
Write-Output "countries={""countries"":$($countries | ConvertTo-Json -Compress)}" >> $Env:GITHUB_OUTPUT
