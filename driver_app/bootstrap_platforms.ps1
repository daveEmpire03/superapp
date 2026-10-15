$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("bokku-driver-platforms-" + [guid]::NewGuid().ToString("N"))
$GeneratedRoot = Join-Path $TempRoot "app"

try {
    New-Item -ItemType Directory -Path $TempRoot -Force | Out-Null
    flutter create --empty --project-name bokku_driver_app --platforms android,ios $GeneratedRoot
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter platform generation failed with exit code $LASTEXITCODE."
    }

    Copy-Item -Path (Join-Path $GeneratedRoot "android") -Destination $ProjectRoot -Recurse -Force
    Copy-Item -Path (Join-Path $GeneratedRoot "ios") -Destination $ProjectRoot -Recurse -Force

    $Manifest = Join-Path $ProjectRoot "android/app/src/main/AndroidManifest.xml"
    $Xml = Get-Content -Path $Manifest -Raw
    $Permissions = @'
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
'@
    foreach ($Permission in @(
        'android.permission.INTERNET',
        'android.permission.ACCESS_COARSE_LOCATION',
        'android.permission.ACCESS_FINE_LOCATION'
    )) {
        if ($Xml -notmatch [regex]::Escape($Permission)) {
            $Xml = [regex]::Replace($Xml, '<application', ($Permissions + [Environment]::NewLine + '    <application'), 1)
            break
        }
    }
    foreach ($Permission in @(
        'android.permission.INTERNET',
        'android.permission.ACCESS_COARSE_LOCATION',
        'android.permission.ACCESS_FINE_LOCATION'
    )) {
        if ($Xml -notmatch [regex]::Escape($Permission)) {
            throw "Failed to add Android permission $Permission."
        }
    }
    Set-Content -Path $Manifest -Value $Xml -Encoding UTF8

    $InfoPlist = Join-Path $ProjectRoot "ios/Runner/Info.plist"
    $Plist = Get-Content -Path $InfoPlist -Raw
    if ($Plist -notmatch 'NSLocationWhenInUseUsageDescription') {
        $LocationEntry = @'
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Bokku Driver uses your location to find nearby jobs and share your location during active deliveries.</string>
'@
        $Plist = $Plist -replace '</dict>', ($LocationEntry + [Environment]::NewLine + '</dict>')
        Set-Content -Path $InfoPlist -Value $Plist -Encoding UTF8
    }

    Write-Host "Android and iOS platform scaffolding generated under $ProjectRoot."
    Write-Host "Next run: cd $ProjectRoot; flutter pub get"
}
finally {
    if (Test-Path $TempRoot) {
        Remove-Item -Path $TempRoot -Recurse -Force
    }
}
