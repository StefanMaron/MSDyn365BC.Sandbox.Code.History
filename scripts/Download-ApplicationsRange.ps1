param(
    [Parameter(Mandatory=$true)]
    [string]$ArtifactUrl,

    [Parameter(Mandatory=$true)]
    [string]$TargetFolderPrefix,

    [string]$OutputPath
)

try {
    # HEAD request to verify Range support and get Content-Length
    $response = Invoke-WebRequest -Uri $ArtifactUrl -Method Head -UseBasicParsing
    $acceptRanges = $response.Headers['Accept-Ranges'] | Select-Object -First 1
    if ($acceptRanges -ne 'bytes') {
        Write-Host "Range requests not supported (Accept-Ranges: $acceptRanges)"
        return $null
    }

    $totalSize = [long]($response.Headers['Content-Length'] | Select-Object -First 1)
    Write-Host "Artifact size: $([math]::Round($totalSize / 1MB)) MB, Range requests supported"

    # Create output directory
    if (-not $OutputPath) {
        $OutputPath = Join-Path ([System.IO.Path]::GetTempPath()) "range-extract-$(Get-Random)"
    }
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

    # Call Python script
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $PythonScript = Join-Path $ScriptDir "download_range_helper.py"

    $result = & python3 $PythonScript $ArtifactUrl $totalSize $TargetFolderPrefix $OutputPath 2>&1
    $result | ForEach-Object { Write-Host $_ }

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Range download failed (exit code: $LASTEXITCODE)"
        if (Test-Path $OutputPath) { Remove-Item -Recurse -Force $OutputPath }
        return $null
    }

    # Verify output has zip files
    $zipFiles = Get-ChildItem -Path $OutputPath -Filter "*.zip" -ErrorAction SilentlyContinue
    if (-not $zipFiles -or $zipFiles.Count -eq 0) {
        Write-Host "No zip files found in output directory"
        if (Test-Path $OutputPath) { Remove-Item -Recurse -Force $OutputPath }
        return $null
    }

    Write-Host "Range download complete: $($zipFiles.Count) zip files in $OutputPath"
    return $OutputPath
}
catch {
    Write-Host "Range download error: $_"
    if ($OutputPath -and (Test-Path $OutputPath)) { Remove-Item -Recurse -Force $OutputPath -ErrorAction SilentlyContinue }
    return $null
}
