# ============================================================
# Windows Step 1 — Run in PowerShell as Administrator
# Enables WSL and Virtual Machine Platform, then restarts
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
Write-Host "  OpenCode Setup — Windows Step 1 of 2"
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  This script will enable the Windows features"
Write-Host "  needed for WSL2, then restart your PC."
Write-Host ""
Read-Host "Press Enter to continue or Ctrl+C to cancel"

# --- Enable WSL ---
Write-Host ""
Write-Host "[1/2] Enabling Windows Subsystem for Linux..." -ForegroundColor Cyan
$result1 = dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

if ($result1 -match "already enabled") {
    Write-Host "    ✓ WSL already enabled" -ForegroundColor Green
} else {
    Write-Host "    ✓ WSL enabled" -ForegroundColor Green
}

# --- Enable Virtual Machine Platform ---
Write-Host ""
Write-Host "[2/3] Enabling Virtual Machine Platform..." -ForegroundColor Cyan
$result2 = dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

if ($result2 -match "already enabled") {
    Write-Host "    ✓ Virtual Machine Platform already enabled" -ForegroundColor Green
} else {
    Write-Host "    ✓ Virtual Machine Platform enabled" -ForegroundColor Green
}

# --- Enable Hyper-V ---
Write-Host ""
Write-Host "[3/3] Enabling Hyper-V..." -ForegroundColor Cyan
$result3 = dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart

if ($result3 -match "already enabled") {
    Write-Host "    ✓ Hyper-V already enabled" -ForegroundColor Green
} else {
    Write-Host "    ✓ Hyper-V enabled" -ForegroundColor Green
}

# --- Restart ---
Write-Host ""
Write-Host "=========================================" -ForegroundColor Yellow
Write-Host "  Restart required"
Write-Host "=========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Your PC will restart in 15 seconds." -ForegroundColor Yellow
Write-Host ""
Write-Host "  After restarting, open PowerShell as Administrator" -ForegroundColor Yellow
Write-Host "  and run Step 2:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  irm https://raw.githubusercontent.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA/main/windows-step-2.ps1 | iex" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Press Ctrl+C now to cancel the restart." -ForegroundColor Yellow
Write-Host ""

Start-Sleep -Seconds 15
Restart-Computer
