# Build script to convert setup-wizard.ps1 to EXE
# Requires PS2EXE - install with: dotnet tool install -g ps2exe

param(
    [string]$InputFile = "setup-wizard.ps1",
    [string]$OutputFile = "OpenCodeSetup.exe"
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not (Get-Command ps2exe -ErrorAction SilentlyContinue)) {
    Write-Host "PS2EXE not found. Installing..." -ForegroundColor Yellow
    dotnet tool install -g ps2exe
}

$inputPath = Join-Path $scriptDir $InputFile
$outputPath = Join-Path $scriptDir $OutputFile

if (-not (Test-Path $inputPath)) {
    Write-Host "Error: $InputFile not found in script directory" -ForegroundColor Red
    exit 1
}

Write-Host "Building $OutputFile..." -ForegroundColor Cyan

ps2exe -noconsole -onefile -x86 $inputPath $outputPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "Success! EXE created at: $outputPath" -ForegroundColor Green
} else {
    Write-Host "Build failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    exit 1
}