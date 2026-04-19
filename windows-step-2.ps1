# ============================================================
# Windows Step 2 — Run in PowerShell as Administrator
# Run this after restarting from windows-step-1.ps1
# Sets WSL2 as default, updates kernel, imports Ubuntu as "tutorial"
# github.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA
# ============================================================

# Auto-elevate if not running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Write-Host "Not running as Administrator — relaunching elevated..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  OpenCode Setup — Windows Step 2 of 2"
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  This script will set up WSL2 and install"
Write-Host "  Ubuntu as a distro named 'tutorial'."
Write-Host ""
Read-Host "Press Enter to continue or Ctrl+C to cancel"

# --- Set WSL2 as default ---
Write-Host ""
Write-Host "[1/3] Setting WSL2 as default version..." -ForegroundColor Cyan
wsl --set-default-version 2
Write-Host "    ✓ WSL2 set as default" -ForegroundColor Green

# --- Update WSL kernel ---
Write-Host ""
Write-Host "[2/3] Updating WSL kernel..." -ForegroundColor Cyan
wsl --update
Write-Host "    ✓ WSL kernel up to date" -ForegroundColor Green

# --- Download and import Ubuntu as "tutorial" ---
Write-Host ""
Write-Host "[3/3] Downloading Ubuntu 24.04 and importing as 'tutorial'..." -ForegroundColor Cyan
Write-Host ""
Write-Host "      This may take a few minutes depending on your connection." -ForegroundColor Yellow
Write-Host ""

$wslDir = "C:\WSL\tutorial"
$tarPath = "$env:TEMP\ubuntu-wsl.tar.gz"

if (!(Test-Path $wslDir)) {
    New-Item -ItemType Directory -Path $wslDir | Out-Null
}

# Check if tutorial distro already exists
$existingDistros = wsl --list --quiet 2>$null
if ($existingDistros -match "tutorial") {
    Write-Host "    ! A distro named 'tutorial' already exists." -ForegroundColor Yellow
    Write-Host ""
    $overwrite = Read-Host "    Unregister it and start fresh? (y/n)"
    if ($overwrite -eq "y") {
        wsl --unregister tutorial
        Write-Host "    ✓ Old 'tutorial' distro removed" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "    Skipping import — existing 'tutorial' distro kept." -ForegroundColor Yellow
        Write-Host "    Launch it with: wsl -d tutorial" -ForegroundColor Cyan
        exit 0
    }
}

Write-Host "      Downloading Ubuntu 24.04 rootfs..."
curl.exe -L -o $tarPath https://cloud-images.ubuntu.com/wsl/noble/current/ubuntu-noble-wsl-amd64-wsl.rootfs.tar.gz

Write-Host "      Importing as 'tutorial'..."
wsl --import tutorial $wslDir $tarPath

Write-Host "    ✓ Ubuntu imported as 'tutorial'" -ForegroundColor Green

# --- Done ---
Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "  Windows setup complete!"
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  IMPORTANT: Install your NVIDIA GPU driver before continuing:" -ForegroundColor Yellow
Write-Host "  https://www.nvidia.com/drivers" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Then launch your Linux environment:" -ForegroundColor Yellow
Write-Host "  wsl -d tutorial" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Once inside WSL, run the Linux setup script:" -ForegroundColor Yellow
Write-Host "  bash <(curl -fsSL https://raw.githubusercontent.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA/main/setup.sh)" -ForegroundColor Cyan
Write-Host ""
