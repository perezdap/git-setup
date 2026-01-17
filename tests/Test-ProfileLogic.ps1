# tests/Test-ProfileLogic.ps1
. ./setup.ps1

# Mock git
function git {
    param($a, $b, $c, $d)
    # Just return success
}

$tempTarget = Join-Path $env:TEMP "GitSetupTest"
if (-not (Test-Path $tempTarget)) {
    New-Item -ItemType Directory -Path $tempTarget -Force | Out-Null
}
$profileName = "test-logic-ps"

Save-GitProfile -TargetDir $tempTarget -Name "Logic Test" -Email "logic@test.com" -ProfileName $profileName

$configFile = Join-Path $HOME ".gitconfig-$profileName"
if (Test-Path $configFile) {
    Write-Host "PASS: Profile config file created"
    $content = Get-Content $configFile -Raw
    if ($content -match "email = logic@test.com") {
        Write-Host "PASS: Config content correct"
    } else {
        Write-Error "FAIL: Config content incorrect"
        exit 1
    }
    Remove-Item $configFile
} else {
    Write-Error "FAIL: Profile config file not created"
    exit 1
}
