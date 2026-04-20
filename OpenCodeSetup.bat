@echo off
title OpenCode Setup
echo.
echo ==========================================
echo   OpenCode Setup
echo ==========================================
echo.
echo Downloading and running the setup wizard...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA/main/setup-wizard.ps1 | iex"

echo.
echo Setup complete!
pause