# Options
$ARCH = ($env:RUNNER_ARCH -split ':')[0].ToLower()
$OS = ($env:RUNNER_OS -split ':')[0].ToLower()

# Args
$FLUTTER_VERSION = $args[0]
if (-not $FLUTTER_VERSION) { $FLUTTER_VERSION = "3.0.2" }
$FLUTTER_CHANNEL = $args[1]
if (-not $FLUTTER_CHANNEL) { $FLUTTER_CHANNEL = "stable" }
$FLUTTER_OS = $OS

# Detect the latest version
if ($FLUTTER_VERSION -eq "latest") {
    Write-Host "Detecting latest version..."
    Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/releases_$OS.json" -OutFile "$env:RUNNER_TEMP/flutter_release.json"
    $CURRENT_RELEASE = (Get-Content "$env:RUNNER_TEMP/flutter_release.json" | ConvertFrom-Json).current_release.$FLUTTER_CHANNEL
    $FLUTTER_VERSION = (Get-Content "$env:RUNNER_TEMP/flutter_release.json" | ConvertFrom-Json).releases | Where-Object { $_.hash -eq $CURRENT_RELEASE } | Select-Object -ExpandProperty version
    Remove-Item "$env:RUNNER_TEMP/flutter_release.json"
}

# OS archive file extension
$EXT = "zip"
if ($OS -eq "linux") {
    $EXT = "tar.xz"
}

# Apple Intel or Apple Silicon
if ($OS -eq "macos" -and $ARCH -eq 'arm64' -and $FLUTTER_VERSION -like "3.*") {
    $FLUTTER_OS = "${FLUTTER_OS}_$ARCH"
}

$FLUTTER_RUNNER_TOOL_CACHE = "$env:RUNNER_TOOL_CACHE/flutter-$env:RUNNER_OS-$FLUTTER_VERSION-$env:RUNNER_ARCH"

$FLUTTER_RELEASE_URL = "https://storage.googleapis.com/flutter_infra_release/releases"

if (-not (Test-Path $FLUTTER_RUNNER_TOOL_CACHE)) {
    Write-Host "Installing Flutter SDK version \"$FLUTTER_VERSION\" from the $FLUTTER_CHANNEL channel on $FLUTTER_OS"
    $FLUTTER_BUILD = "flutter_${FLUTTER_OS}_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.$EXT"
    $FLUTTER_DOWNLOAD_URL = "$FLUTTER_RELEASE_URL/$FLUTTER_CHANNEL/$FLUTTER_OS/$FLUTTER_BUILD"

    Write-Host "Downloading $FLUTTER_DOWNLOAD_URL"

    $DOWNLOAD_PATH = "$env:TEMP\$FLUTTER_BUILD"
    Invoke-WebRequest -Uri $FLUTTER_DOWNLOAD_URL -OutFile $DOWNLOAD_PATH

    Write-Host "Finished downloading $FLUTTER_DOWNLOAD_URL"

    New-Item -ItemType Directory -Path $FLUTTER_RUNNER_TOOL_CACHE -ErrorAction SilentlyContinue | Out-Null

    if ($OS -eq "linux") {
        tar -C $FLUTTER_RUNNER_TOOL_CACHE -xf $DOWNLOAD_PATH > $null
    }
    else {
        Write-Host "Unzipping $FLUTTER_DOWNLOAD_URL"
        Expand-Archive -Path $DOWNLOAD_PATH -DestinationPath $FLUTTER_RUNNER_TOOL_CACHE
    }

    if (-not $?) {
        Write-Host "::error::Download failed! Please check passed arguments."
        exit 1
    }
}
else {
    Write-Host "Cache restored Flutter SDK version \"$FLUTTER_VERSION\" from the $FLUTTER_CHANNEL channel on $FLUTTER_OS"
}

# Configure pub to use a fixed location.
Add-Content -Path $env:GITHUB_ENV -Value "PUB_CACHE=$env:HOME/.pub-cache"

# Update paths.
Add-Content -Path $env:GITHUB_PATH -Value "$env:HOME/.pub-cache/bin"
Add-Content -Path $env:GITHUB_PATH -Value "$FLUTTER_RUNNER_TOOL_CACHE/flutter/bin"

# Report success, and print version.
Write-Host "Succesfully installed Flutter SDK:"
& "$FLUTTER_RUNNER_TOOL_CACHE/flutter/bin/dart" --version
& "$FLUTTER_RUNNER_TOOL_CACHE/flutter/bin/flutter" --version