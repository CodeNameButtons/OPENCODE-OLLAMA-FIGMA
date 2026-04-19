#!/bin/bash

# ============================================================
# OpenCode + Ollama + Figma MCP Full Setup Script
# Run inside a fresh WSL Ubuntu terminal
# github.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA
#
# Usage:
# bash <(curl -fsSL https://raw.githubusercontent.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA/main/setup.sh)
# ============================================================

set -e

# Colours
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}  OpenCode + Ollama Full Setup${NC}"
echo -e "${CYAN}  github.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""
echo "This will install:"
echo "  - System dependencies"
echo "  - Node.js 20 via NVM"
echo "  - Ollama (local model runner)"
echo "  - A local AI model"
echo "  - OpenCode (AI coding agent)"
echo "  - Figma MCP (optional)"
echo ""
echo -e "${YELLOW}You'll need around 8GB free disk space.${NC}"
echo -e "${YELLOW}The model download will take a while depending on your connection.${NC}"
echo ""
read -p "Ready to begin? Press Enter to continue or Ctrl+C to cancel..."

# ─────────────────────────────────────────
# STEP 1: System packages
# ─────────────────────────────────────────
echo ""
echo -e "${CYAN}[1/8] Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl build-essential git

echo -e "${GREEN}    ✓ System packages ready${NC}"

# ─────────────────────────────────────────
# STEP 2: Create a non-root user (if running as root)
# ─────────────────────────────────────────
if [ "$EUID" -eq 0 ]; then
  echo ""
  echo -e "${CYAN}[2/8] Setting up user account...${NC}"
  echo ""
  read -p "      Enter a username to create: " NEW_USER
  adduser "$NEW_USER"
  usermod -aG sudo "$NEW_USER"
  echo ""
  echo -e "${GREEN}    ✓ User '$NEW_USER' created with sudo access${NC}"
  echo -e "${YELLOW}    Log back in as $NEW_USER and re-run this script to continue.${NC}"
  echo -e "    Run: ${YELLOW}su - $NEW_USER${NC}"
  echo ""
  exit 0
else
  echo ""
  echo -e "${CYAN}[2/8] Running as user: $(whoami)${NC}"
  echo -e "${GREEN}    ✓ User check passed${NC}"
fi

# ─────────────────────────────────────────
# STEP 3: Node.js via NVM
# ─────────────────────────────────────────
echo ""
echo -e "${CYAN}[3/8] Installing Node.js 20 via NVM...${NC}"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 20
nvm use 20

echo -e "${GREEN}    ✓ Node $(node --version) installed${NC}"

# ─────────────────────────────────────────
# STEP 4: GPU check
# ─────────────────────────────────────────
echo ""
echo -e "${CYAN}[4/8] Checking for GPU...${NC}"

HAS_GPU=false

if command -v nvidia-smi &>/dev/null; then
  HAS_GPU=true
  echo -e "${GREEN}    ✓ NVIDIA GPU detected:${NC}"
  nvidia-smi --query-gpu=name --format=csv,noheader
  echo -e "${GREEN}    Ollama will use GPU acceleration automatically.${NC}"
else
  echo -e "${YELLOW}    ! No NVIDIA GPU detected via nvidia-smi.${NC}"
  echo -e "${YELLOW}    Ollama will run on CPU. A smaller model will be selected.${NC}"
  echo ""
  read -p "    Continue with CPU-only mode? (y/n): " GPU_CHOICE
  if [[ "$GPU_CHOICE" != "y" ]]; then
    echo "Exiting. Install your NVIDIA drivers on Windows first, then re-run."
    exit 1
  fi
fi

# ─────────────────────────────────────────
# STEP 5: Ollama + model selection
# ─────────────────────────────────────────
echo ""
echo -e "${CYAN}[5/8] Installing Ollama...${NC}"

curl -fsSL https://ollama.com/install.sh | sh

# Start Ollama in background
ollama serve &>/dev/null &
OLLAMA_PID=$!
echo "    Waiting for Ollama to start..."
sleep 6

if ! curl -s http://localhost:11434 &>/dev/null; then
  echo -e "${YELLOW}    Ollama didn't respond, waiting a bit longer...${NC}"
  sleep 10
fi

echo -e "${GREEN}    ✓ Ollama running on port 11434${NC}"

# Model picker
echo ""
echo -e "${CYAN}    Choose a model to install:${NC}"
echo ""

if [ "$HAS_GPU" = true ]; then
  echo "      1) qwen2.5-coder:7b   (~4.7GB) — Recommended for GPU, best code quality"
  echo "      2) qwen2.5-coder:1.5b (~1.0GB) — Smaller, still good for GPU"
  echo "      3) deepseek-coder-v2  (~8.9GB) — Larger, high quality, needs more VRAM"
  echo "      4) mistral:7b         (~4.1GB) — Great general purpose model"
else
  echo "      1) qwen2.5-coder:1.5b (~1.0GB) — Recommended for CPU, fast responses"
  echo "      2) mistral:7b         (~4.1GB) — Larger, slower on CPU but more capable"
fi

echo ""
read -p "    Enter choice [1]: " MODEL_CHOICE
MODEL_CHOICE=${MODEL_CHOICE:-1}

if [ "$HAS_GPU" = true ]; then
  case "$MODEL_CHOICE" in
    1) MODEL="qwen2.5-coder:7b" ;;
    2) MODEL="qwen2.5-coder:1.5b" ;;
    3) MODEL="deepseek-coder-v2" ;;
    4) MODEL="mistral:7b" ;;
    *) MODEL="qwen2.5-coder:7b" ;;
  esac
else
  case "$MODEL_CHOICE" in
    1) MODEL="qwen2.5-coder:1.5b" ;;
    2) MODEL="mistral:7b" ;;
    *) MODEL="qwen2.5-coder:1.5b" ;;
  esac
fi

echo ""
echo -e "    Pulling ${CYAN}${MODEL}${NC} — this will take a while, don't close the terminal..."
echo ""

ollama pull "$MODEL"

# Set context window to 32k for proper agentic tool use
echo ""
echo "    Configuring context window to 32k for ${MODEL}..."

ollama run "$MODEL" <<EOF
/set parameter num_ctx 32768
/save $MODEL
/bye
EOF

echo -e "${GREEN}    ✓ Model ready: ${MODEL} with 32k context${NC}"

# ─────────────────────────────────────────
# STEP 6: Figma MCP (optional)
# ─────────────────────────────────────────
echo ""
echo -e "${CYAN}[6/8] Figma MCP Integration (optional)${NC}"
echo ""
echo "      Connecting Figma lets OpenCode read your design files,"
echo "      inspect components, extract tokens, and generate code"
echo "      directly from your Figma designs."
echo ""
read -p "    Would you like to connect Figma? (y/n): " FIGMA_CHOICE

FIGMA_API_KEY=""
FIGMA_MCP_BLOCK=""

if [[ "$FIGMA_CHOICE" == "y" ]]; then
  echo ""
  echo -e "    ${YELLOW}You'll need a Figma Personal Access Token.${NC}"
  echo ""
  echo "    To get one:"
  echo "      1. Go to figma.com and log in"
  echo "      2. Click your profile picture → Settings"
  echo "      3. Scroll to 'Personal access tokens'"
  echo "      4. Click 'Generate new token'"
  echo "      5. Give it a name (e.g. opencode)"
  echo "      6. Set scopes: File content → Read only"
  echo "      7. Copy the token — it starts with figd_"
  echo ""
  read -p "    Paste your Figma API key here: " FIGMA_API_KEY
  echo ""

  if [[ -z "$FIGMA_API_KEY" ]]; then
    echo -e "${YELLOW}    No key entered — skipping Figma setup.${NC}"
    FIGMA_CHOICE="n"
  elif [[ "$FIGMA_API_KEY" != figd_* ]]; then
    echo -e "${YELLOW}    Warning: token doesn't start with figd_ — it may be invalid.${NC}"
    echo -e "${YELLOW}    Continuing anyway, but double-check your token if Figma doesn't connect.${NC}"
  else
    echo -e "${GREEN}    ✓ Figma token accepted${NC}"
  fi

  if [[ "$FIGMA_CHOICE" == "y" && -n "$FIGMA_API_KEY" ]]; then
    if ! grep -q 'FIGMA_API_KEY' ~/.bashrc; then
      echo "export FIGMA_API_KEY=\"${FIGMA_API_KEY}\"" >> ~/.bashrc
    else
      sed -i "s|^export FIGMA_API_KEY=.*|export FIGMA_API_KEY=\"${FIGMA_API_KEY}\"|" ~/.bashrc
    fi
    export FIGMA_API_KEY="$FIGMA_API_KEY"

    FIGMA_MCP_BLOCK=',
  "mcp": {
    "figma": {
      "type": "remote",
      "url": "https://mcp.figma.com/mcp",
      "oauth": false,
      "headers": {
        "Authorization": "Bearer ${FIGMA_API_KEY}"
      },
      "enabled": true
    }
  }'
  fi
fi

# ─────────────────────────────────────────
# STEP 7: OpenCode
# ─────────────────────────────────────────
echo ""
echo -e "${CYAN}[7/8] Installing OpenCode...${NC}"

curl -fsSL https://opencode.ai/install | bash

if ! grep -q '.opencode/bin' ~/.bashrc; then
  echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> ~/.bashrc
fi

export PATH="$HOME/.opencode/bin:$PATH"

echo -e "${GREEN}    ✓ OpenCode $(opencode --version) installed${NC}"

# ─────────────────────────────────────────
# STEP 8: Write full config
# ─────────────────────────────────────────
echo ""
echo -e "${CYAN}[8/8] Writing OpenCode config...${NC}"

mkdir -p ~/.config/opencode

cat > ~/.config/opencode/config.json << EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "model": "ollama/${MODEL}",
  "autoupdate": true,
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (local)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "${MODEL}": {
          "name": "${MODEL}",
          "tools": true
        }
      }
    }
  }${FIGMA_MCP_BLOCK}
}
EOF

echo -e "${GREEN}    ✓ Config written to ~/.config/opencode/config.json${NC}"

if [[ "$FIGMA_CHOICE" == "y" && -n "$FIGMA_API_KEY" ]]; then
  echo -e "${GREEN}    ✓ Figma MCP included in config${NC}"
  echo -e "${YELLOW}    Note: Your API key is stored in ~/.bashrc as FIGMA_API_KEY${NC}"
  echo -e "${YELLOW}    It is NOT hardcoded into the config file — safe to share config.${NC}"
fi

# ─────────────────────────────────────────
# Done
# ─────────────────────────────────────────
echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Everything is installed and configured!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "  Default model: ${MODEL}"
echo ""
echo "  To start coding with OpenCode:"
echo ""
echo -e "  1. Start Ollama:   ${CYAN}ollama serve${NC}"
echo -e "  2. New terminal,   cd into your project"
echo -e "  3. Launch:         ${CYAN}opencode${NC}"
echo ""

if [[ "$FIGMA_CHOICE" == "y" && -n "$FIGMA_API_KEY" ]]; then
echo -e "  Figma MCP is connected. Inside OpenCode, type:"
echo -e "  ${CYAN}/mcp${NC} to verify Figma appears as an active tool."
echo ""
fi

echo -e "  Reload your shell first: ${YELLOW}source ~/.bashrc${NC}"
echo ""
echo "  Config:   ~/.config/opencode/config.json"
echo "  Sessions: ~/.local/share/opencode/"
echo ""
echo "  ─────────────────────────────────────────"
echo "  github.com/CodeNameButtons/OPENCODE-OLLAMA-FIGMA"
echo "  ─────────────────────────────────────────"
echo ""
