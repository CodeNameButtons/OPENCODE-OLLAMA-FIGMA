# ============================================================
# Windows Step 2 — Run in PowerShell as Administrator
# Run this after restarting from windows-step-1.ps1
# Sets WSL2 as default, updates kernel, installs Ubuntu as "tutorial"
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

# --- Check for existing tutorial distro ---
Write-Host ""
Write-Host "[3/3] Installing Ubuntu 24.04 as 'tutorial'..." -ForegroundColor Cyan
Write-Host ""

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
        Write-Host "    Skipping install — existing 'tutorial' distro kept." -ForegroundColor Yellow
        Write-Host "    Launch it with: wsl -d tutorial" -ForegroundColor Cyan
        exit 0
    }
}

# --- Install Ubuntu using WSL's built-in command ---
Write-Host "      Installing Ubuntu-24.04 via WSL (this may take a few minutes)..." -ForegroundColor Yellow
$installOutput = wsl --install -d Ubuntu-24.04 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "    ✗ Failed to install Ubuntu" -ForegroundColor Red
    Write-Host "    Error details: $installOutput" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    This usually means:" -ForegroundColor Yellow
    Write-Host "    - Hyper-V is not enabled (rerun Step 1)" -ForegroundColor Yellow
    Write-Host "    - Virtualization is disabled in BIOS" -ForegroundColor Yellow
    Write-Host "    - Internet connection issue" -ForegroundColor Yellow
    exit 1
}

# --- Rename the distro to 'tutorial' ---
$installedDistros = wsl --list --quiet 2>$null
if ($installedDistros -match "Ubuntu-24.04") {
    Write-Host "      Renaming Ubuntu-24.04 to 'tutorial'..." -ForegroundColor Yellow
    wsl --rename Ubuntu-24.04 tutorial
} elseif ($installedDistros -match "Ubuntu") {
    Write-Host "      Renaming Ubuntu to 'tutorial'..." -ForegroundColor Yellow
    wsl --rename Ubuntu tutorial
}

# Verify the distro was created
$verifyDistros = wsl --list --quiet 2>$null
if ($verifyDistros -match "tutorial") {
    Write-Host "    ✓ Ubuntu installed as 'tutorial'" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "    ✗ Could not verify 'tutorial' distro installation" -ForegroundColor Red
    Write-Host "    Run 'wsl --list' to check your distros." -ForegroundColor Yellow
    exit 1
}

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