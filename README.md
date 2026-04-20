# OpenCode + Ollama + Figma — WSL Setup

Three scripts that set up a complete local AI coding environment on Windows using WSL, Ollama, and OpenCode. No cloud. No API bill. No subscription.

## What gets installed

- **WSL2 + Ubuntu 24.04** — Linux environment inside Windows
- **Node.js 20** via NVM
- **Ollama** — runs AI models locally on your machine
- **A local AI model** — you choose during setup
- **OpenCode** — terminal-based AI coding agent
- **Figma MCP** — optional, connects your Figma files to OpenCode

---

## Requirements

- Windows 10 (21H2+) or Windows 11
- At least 8GB RAM (16GB recommended)
- At least 8GB free disk space
- NVIDIA GPU recommended — works on CPU too, just slower

---

## Quick Start (Two Clicks)

### Click 1: Download
Download `OpenCodeSetup.bat` from this repo (or copy the code below into a new file).

### Click 2: Run
Double-click `OpenCodeSetup.bat` — it will download and launch the setup wizard automatically.

That's it! The wizard will guide you through everything.

---

## Alternative: EXE Version

If you prefer an EXE:
1. Download `OpenCodeSetup.exe` from [Releases](https://github.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA/releases)
2. Right-click → Run as Administrator

---

## Building the EXE (for developers)

## Manual Setup (3 Steps)

If you prefer to run each step separately, follow these instructions:

### Step 1 — Enable WSL features

Open **PowerShell as Administrator** and run:

```powershell
irm https://raw.githubusercontent.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA/main/windows-step-1.ps1 | iex
```

This enables Windows Subsystem for Linux, Virtual Machine Platform, and Hyper-V (required for WSL2), then **automatically restarts your PC**.

---

## Step 2 — Install WSL2 and Ubuntu (after restart)

Open **PowerShell as Administrator** again and run:

```powershell
irm https://raw.githubusercontent.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA/main/windows-step-2.ps1 | iex
```

This sets WSL2 as default, updates the kernel, and imports Ubuntu 24.04 as a distro named `tutorial`.

> **Before Step 3:** Install your NVIDIA GPU driver from [nvidia.com/drivers](https://www.nvidia.com/drivers)

---

## Step 3 — Linux setup (inside WSL)

Launch your new distro:

```powershell
wsl -d tutorial
```

Then run the Linux setup script:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA/main/setup.sh)
```

The script walks you through everything interactively — model selection, optional Figma connection, and full config generation.

---

## Starting OpenCode after setup

```bash
# Terminal 1 — keep Ollama running
ollama serve

# Terminal 2 — inside your project
cd ~/your-project
opencode
```

---

## Figma MCP

If you connected Figma during setup, your API key is stored in `~/.bashrc` as `FIGMA_API_KEY`. It is not hardcoded into the config file, so it's safe to share or commit your config.

To verify Figma is connected, type `/mcp` inside OpenCode and check for `figma` in the list.

**To get a Figma Personal Access Token:**
1. figma.com → click your profile picture → Settings
2. Scroll to **Personal access tokens**
3. Generate a new token — set **File content → Read only**
4. Your token will start with `figd_`

---

## Config locations

```
~/.config/opencode/config.json    ← provider, model, and MCP settings
~/.local/share/opencode/           ← sessions and conversation history
```

---

## Cleaning up the tutorial distro

When you're done and want to remove it entirely:

```powershell
wsl --unregister tutorial
```

Your original WSL setup is completely unaffected.

---

## Troubleshooting

### WSL2 install fails with "HCS_E_HYPERV_NOT_INSTALLED"
Re-run Step 1 to enable Hyper-V:
```powershell
irm https://raw.githubusercontent.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA/main/windows-step-1.ps1 | iex
```
Then restart and try Step 2 again.

### Other WSL errors
- Make sure **Virtualization** is enabled in your BIOS/UEFI
- Ensure Windows is up to date
- Run `wsl --update` in PowerShell to update the WSL kernel

---

## Building the EXE (for developers)

If you want to build the EXE yourself:

```powershell
# Install .NET SDK if not already installed
winget install Microsoft.DotNet.SDK

# Install PS2EXE
dotnet tool install -g ps2exe

# Build
pwsh -File build.ps1
```

The EXE will be created as `OpenCodeSetup.exe`.

---

Made by [Buttons Digital](https://buttonsdigital.co.uk)
