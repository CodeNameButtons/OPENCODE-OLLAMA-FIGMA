# ============================================================
# OpenCode Setup Wizard - Single Script
# Run in PowerShell as Administrator
# github.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:Progress = 0
$script:Log = ""

function Write-Log {
    param([string]$Message, [string]$Type = "Info")
    $script:Log += "[$Type] $Message`n"
    $script:LogBox.AppendText("[$Type] $Message`n")
    $script:LogBox.SelectionStart = $script:LogBox.Text.Length
    $script:LogBox.ScrollToCaret()
}

function Show-Message {
    param([string]$Title, [string]$Message, [string]$Type = "Info")
    if ($Type -eq "Error") {
        [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    } elseif ($Type -eq "Warning") {
        [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    } else {
        [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
}

function Show-Confirm {
    param([string]$Title, [string]$Message)
    return ([System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question) -eq "Yes")
}

function Enable-WindowsFeatures {
    Write-Log "Enabling Windows Subsystem for Linux..." "Info"
    $result1 = dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart 2>&1
    if ($result1 -match "already enabled") {
        Write-Log "WSL already enabled" "Success"
    } else {
        Write-Log "WSL enabled" "Success"
    }

    Write-Log "Enabling Virtual Machine Platform..." "Info"
    $result2 = dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart 2>&1
    if ($result2 -match "already enabled") {
        Write-Log "Virtual Machine Platform already enabled" "Success"
    } else {
        Write-Log "Virtual Machine Platform enabled" "Success"
    }

    Write-Log "Enabling Hyper-V..." "Info"
    $result3 = dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart 2>&1
    if ($result3 -match "already enabled") {
        Write-Log "Hyper-V already enabled" "Success"
    } else {
        Write-Log "Hyper-V enabled" "Success"
    }

    $script:Progress = 1
}

function Install-WSLAndUbuntu {
    Write-Log "Setting WSL2 as default version..." "Info"
    wsl --set-default-version 2 2>&1 | Out-Null
    Write-Log "WSL2 set as default" "Success"

    Write-Log "Updating WSL kernel..." "Info"
    wsl --update 2>&1 | Out-Null
    Write-Log "WSL kernel updated" "Success"

    $existingDistros = wsl --list --quiet 2>$null
    if ($existingDistros -match "tutorial") {
        Write-Log "Removing existing 'tutorial' distro..." "Warning"
        wsl --unregister tutorial 2>&1 | Out-Null
    }

    Write-Log "Installing Ubuntu 24.04 (this may take a few minutes)..." "Warning"
    $installOutput = wsl --install -d Ubuntu-24.04 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Log "Failed to install Ubuntu: $installOutput" "Error"
        Show-Message "Installation Failed" "Could not install Ubuntu. Error: $installOutput`n`nThis usually means Hyper-V is not enabled or virtualization is disabled in BIOS." "Error"
        return $false
    }

    $installedDistros = wsl --list --quiet 2>$null
    if ($installedDistros -match "Ubuntu-24.04") {
        wsl --rename Ubuntu-24.04 tutorial 2>&1 | Out-Null
    } elseif ($installedDistros -match "Ubuntu") {
        wsl --rename Ubuntu tutorial 2>&1 | Out-Null
    }

    Write-Log "Ubuntu installed as 'tutorial'" "Success"
    return $true
}

function Invoke-LinuxSetup {
    Write-Log "Starting Linux setup..." "Info"

    $wslScript = @"
echo ''
echo '=============================================='
echo '  OpenCode + Ollama Full Setup'
echo '  github.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA'
echo '=============================================='
echo ''
read -p 'Press Enter to begin the Linux setup...'
bash <(curl -fsSL https://raw.githubusercontent.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA/main/setup.sh)
"@

    $wslScript | Out-File -FilePath "$env:TEMP\opencode_setup.sh" -Encoding UTF8

    Write-Log "Launching Ubuntu terminal for Linux setup..." "Info"
    Start-Process "wsl.exe" -ArgumentList "-d tutorial", "bash", "$env:TEMP\opencode_setup.sh" -Wait

    $script:Progress = 3
    return $true
}

# ============================================================
# Main Wizard Form
# ============================================================

$form = New-Object System.Windows.Forms.Form
$form.Text = "OpenCode Setup Wizard"
$form.Size = New-Object System.Drawing.Size(700, 550)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)

# Header
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Dock = "Top"
$headerPanel.Height = 80
$headerPanel.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "OpenCode Setup Wizard"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = "White"
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$titleLabel.AutoSize = $true
$headerPanel.Controls.Add($titleLabel)

$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = "Set up a complete local AI coding environment"
$subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$subtitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$subtitleLabel.Location = New-Object System.Drawing.Point(22, 50)
$subtitleLabel.AutoSize = $true
$headerPanel.Controls.Add($subtitleLabel)

$form.Controls.Add($headerPanel)

# Progress indicators
$progressPanel = New-Object System.Windows.Forms.Panel
$progressPanel.Dock = "Fill"
$progressPanel.Padding = New-Object System.Windows.Forms.Padding(20)

# Step indicators
$stepsLabel = New-Object System.Windows.Forms.Label
$stepsLabel.Text = @"
Step 1: Enable Windows features (WSL, Hyper-V)
Step 2: Install WSL2 and Ubuntu
Step 3: Linux setup (Ollama, OpenCode, optional Figma)
"@
$stepsLabel.Font = New-Object System.Drawing.Font("Consolas", 10)
$stepsLabel.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 180)
$stepsLabel.Location = New-Object System.Drawing.Point(20, 20)
$stepsLabel.AutoSize = $true
$progressPanel.Controls.Add($stepsLabel)

# Log box
$script:LogBox = New-Object System.Windows.Forms.TextBox
$script:LogBox.Multiline = $true
$script:LogBox.ReadOnly = $true
$script:LogBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$script:LogBox.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
$script:LogBox.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 0)
$script:LogBox.BorderStyle = "None"
$script:LogBox.Location = New-Object System.Drawing.Point(20, 120)
$script:LogBox.Size = New-Object System.Drawing.Size(630, 250)
$script:LogBox.ScrollBars = "Vertical"
$progressPanel.Controls.Add($script:LogBox)

# Button panel
$buttonPanel = New-Object System.Windows.Forms.Panel
$buttonPanel.Dock = "Bottom"
$buttonPanel.Height = 60
$buttonPanel.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)

$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "Start Setup"
$startButton.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$startButton.Size = New-Object System.Drawing.Size(150, 35)
$startButton.Location = New-Object System.Drawing.Point(250, 10)
$startButton.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
$startButton.ForeColor = "White"
$startButton.FlatStyle = "Flat"
$startButton.FlatAppearance.BorderSize = 0
$buttonPanel.Controls.Add($startButton)

$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = "Close"
$closeButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$closeButton.Size = New-Object System.Drawing.Size(80, 30)
$closeButton.Location = New-Object System.Drawing.Point(590, 12)
$closeButton.BackColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
$closeButton.ForeColor = "White"
$closeButton.FlatStyle = "Flat"
$buttonPanel.Controls.Add($closeButton)

$form.Controls.Add($buttonPanel)
$form.Controls.Add($progressPanel)

# Event handlers
$startButton.Add_Click({
    if ($script:Progress -eq 0) {
        # Step 1: Enable features
        $startButton.Enabled = $false
        $startButton.Text = "Running..."

        if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
            Show-Message "Administrator Required" "Please run this script as Administrator." "Warning"
            $startButton.Enabled = $true
            $startButton.Text = "Start Setup"
            return
        }

        Enable-WindowsFeatures

        $script:Progress = 1
        $startButton.Text = "Restart Required"
        $startButton.Enabled = $false

        if (Show-Confirm "Restart Required" "Windows features have been enabled. Your PC must restart to continue.`n`nRestart now?") {
            Write-Log "Restarting in 10 seconds..." "Warning"
            Start-Sleep -Seconds 10
            Restart-Computer
        } else {
            Show-Message "Setup Paused" "When you're ready, run this script again and click 'Continue After Restart'." "Info"
            $startButton.Text = "Continue After Restart"
            $startButton.Enabled = $true
        }
    }
    elseif ($script:Progress -eq 1) {
        # Step 2: Install WSL and Ubuntu
        $startButton.Enabled = $false
        $startButton.Text = "Installing..."

        $success = Install-WSLAndUbuntu

        if (-not $success) {
            $startButton.Text = "Retry Step 2"
            $startButton.Enabled = $true
            return
        }

        $script:Progress = 2
        $startButton.Text = "Launch Linux Setup"
        $startButton.Enabled = $true
    }
    elseif ($script:Progress -eq 2) {
        # Step 3: Linux setup
        $startButton.Enabled = $false
        $startButton.Text = "Launching..."

        $nvidiaDriver = Show-Confirm "NVIDIA GPU" "Do you have an NVIDIA GPU?`n`nIf yes, make sure you've installed the NVIDIA driver on Windows before continuing."

        if ($nvidiaDriver) {
            Show-Message "Install NVIDIA Driver" "Please install your NVIDIA driver from https://www.nvidia.com/drivers if you haven't already, then click OK to continue." "Info"
        }

        $success = Invoke-LinuxSetup

        if ($success) {
            $script:Progress = 3
            $startButton.Text = "Setup Complete"
            $startButton.Enabled = $false
            Show-Message "Setup Complete" "Linux setup has been launched in a new terminal.`n`nFollow the prompts in the Ubuntu terminal to complete the setup.`n`nAfter that, you'll be ready to use OpenCode!" "Info"
        } else {
            $startButton.Text = "Retry Step 3"
            $startButton.Enabled = $true
        }
    }
})

$closeButton.Add_Click({
    $form.Close()
})

$form.Add_Shown({
    Write-Log "Welcome to OpenCode Setup Wizard!" "Info"
    Write-Log "Click 'Start Setup' to begin." "Info"
})

[void]$form.ShowDialog()