#!/bin/bash
# ============================================================================
# Portable Neovim Docker Build Configuration Script
# Interactive script to select language support before building
# ============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="portable-nvim:latest"

# ============================================================================
# Functions
# ============================================================================

print_header() {
  echo -e "${BLUE}============================================${NC}"
  echo -e "${BLUE}  Portable Neovim Build Configuration${NC}"
  echo -e "${BLUE}============================================${NC}"
  echo ""
}

show_presets() {
  echo -e "${CYAN}Available Presets:${NC}"
  echo ""
  echo -e "${GREEN}1) Minimal${NC} - Only essential tools"
  echo "   ├─ Neovim, Git, lazygit"
  echo "   ├─ Basic terminal tools (zsh, tmux)"
  echo "   └─ Estimated size: ~800MB-1GB"
  echo ""
  echo -e "${GREEN}2) Standard${NC} - Common development languages (Recommended)"
  echo "   ├─ Minimal preset"
  echo "   ├─ Python (pip, common packages)"
  echo "   ├─ Node.js (npm, neovim support)"
  echo "   └─ Estimated size: ~1.5GB-1.8GB"
  echo ""
  echo -e "${GREEN}3) Full${NC} - All language support"
  echo "   ├─ Standard preset"
  echo "   ├─ Go"
  echo "   ├─ Rust"
  echo "   ├─ PHP + Composer"
  echo "   ├─ Lua + LuaRocks"
  echo "   └─ Estimated size: ~2GB-2.5GB"
  echo ""
  echo -e "${GREEN}4) Custom${NC} - Choose specific languages"
  echo ""
}

get_preset_choice() {
  while true; do
    read -p "Select preset (1-4): " choice
    case $choice in
    1 | 2 | 3 | 4)
      echo $choice
      return
      ;;
    *)
      echo -e "${RED}Invalid choice. Please enter 1-4.${NC}"
      ;;
    esac
  done
}

configure_minimal() {
  INSTALL_PYTHON="false"
  INSTALL_NODEJS="false"
  INSTALL_GO="false"
  INSTALL_RUST="false"
  INSTALL_PHP="false"
  INSTALL_LUA="false"
  INSTALL_RSYNC="false"
}

configure_standard() {
  INSTALL_PYTHON="true"
  INSTALL_NODEJS="true"
  INSTALL_GO="false"
  INSTALL_RUST="false"
  INSTALL_PHP="false"
  INSTALL_LUA="false"
  INSTALL_RSYNC="false"
}

configure_full() {
  INSTALL_PYTHON="true"
  INSTALL_NODEJS="true"
  INSTALL_GO="true"
  INSTALL_RUST="true"
  INSTALL_PHP="true"
  INSTALL_LUA="true"
  INSTALL_RSYNC="true"
}

configure_custom() {
  echo ""
  echo -e "${CYAN}Custom Language Selection:${NC}"
  echo ""

  read -p "Install Python support? (y/n) [y]: " choice
  INSTALL_PYTHON="${choice:-y}"
  [[ "$INSTALL_PYTHON" =~ ^[Yy] ]] && INSTALL_PYTHON="true" || INSTALL_PYTHON="false"

  read -p "Install Node.js support? (y/n) [y]: " choice
  INSTALL_NODEJS="${choice:-y}"
  [[ "$INSTALL_NODEJS" =~ ^[Yy] ]] && INSTALL_NODEJS="true" || INSTALL_NODEJS="false"

  read -p "Install Go support? (y/n) [n]: " choice
  INSTALL_GO="${choice:-n}"
  [[ "$INSTALL_GO" =~ ^[Yy] ]] && INSTALL_GO="true" || INSTALL_GO="false"

  read -p "Install Rust support? (y/n) [n]: " choice
  INSTALL_RUST="${choice:-n}"
  [[ "$INSTALL_RUST" =~ ^[Yy] ]] && INSTALL_RUST="true" || INSTALL_RUST="false"

  read -p "Install PHP support? (y/n) [n]: " choice
  INSTALL_PHP="${choice:-n}"
  [[ "$INSTALL_PHP" =~ ^[Yy] ]] && INSTALL_PHP="true" || INSTALL_PHP="false"

  read -p "Install Lua support? (y/n) [n]: " choice
  INSTALL_LUA="${choice:-n}"
  [[ "$INSTALL_LUA" =~ ^[Yy] ]] && INSTALL_LUA="true" || INSTALL_LUA="false"

  read -p "Install rsync utility? (y/n) [n]: " choice
  INSTALL_RSYNC="${choice:-n}"
  [[ "$INSTALL_RSYNC" =~ ^[Yy] ]] && INSTALL_RSYNC="true" || INSTALL_RSYNC="false"
}

show_configuration() {
  echo ""
  echo -e "${CYAN}Build Configuration Summary:${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

  [[ "$INSTALL_PYTHON" == "true" ]] && echo -e "  ${GREEN}✓${NC} Python + pip + common packages" || echo -e "  ${RED}✗${NC} Python"
  [[ "$INSTALL_NODEJS" == "true" ]] && echo -e "  ${GREEN}✓${NC} Node.js + npm + tree-sitter" || echo -e "  ${RED}✗${NC} Node.js"
  [[ "$INSTALL_GO" == "true" ]] && echo -e "  ${GREEN}✓${NC} Go" || echo -e "  ${RED}✗${NC} Go"
  [[ "$INSTALL_RUST" == "true" ]] && echo -e "  ${GREEN}✓${NC} Rust + Cargo" || echo -e "  ${RED}✗${NC} Rust"
  [[ "$INSTALL_PHP" == "true" ]] && echo -e "  ${GREEN}✓${NC} PHP + Composer" || echo -e "  ${RED}✗${NC} PHP"
  [[ "$INSTALL_LUA" == "true" ]] && echo -e "  ${GREEN}✓${NC} Lua + LuaRocks" || echo -e "  ${RED}✗${NC} Lua"
  [[ "$INSTALL_RSYNC" == "true" ]] && echo -e "  ${GREEN}✓${NC} rsync" || echo -e "  ${RED}✗${NC} rsync"

  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

build_image() {
  echo -e "${GREEN}Building Docker image with selected configuration...${NC}"
  echo ""

  docker build \
    --build-arg INSTALL_PYTHON="$INSTALL_PYTHON" \
    --build-arg INSTALL_NODEJS="$INSTALL_NODEJS" \
    --build-arg INSTALL_GO="$INSTALL_GO" \
    --build-arg INSTALL_RUST="$INSTALL_RUST" \
    --build-arg INSTALL_PHP="$INSTALL_PHP" \
    --build-arg INSTALL_LUA="$INSTALL_LUA" \
    --build-arg INSTALL_RSYNC="$INSTALL_RSYNC" \
    -t ${IMAGE_NAME} \
    .

  if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Build completed successfully!${NC}"
    echo ""

    # Show image size
    SIZE=$(docker images ${IMAGE_NAME} --format "{{.Size}}")
    echo -e "${CYAN}Image size: ${SIZE}${NC}"
    echo ""

    echo -e "${YELLOW}Run the container with:${NC}"
    echo -e "  ${BLUE}./scripts/docker-run.sh run${NC}"
    echo ""
  else
    echo ""
    echo -e "${RED}✗ Build failed!${NC}"
    exit 1
  fi
}

# ============================================================================
# Main
# ============================================================================

print_header
show_presets

PRESET=$(get_preset_choice)

case $PRESET in
1)
  echo -e "${GREEN}Selected: Minimal${NC}"
  configure_minimal
  ;;
2)
  echo -e "${GREEN}Selected: Standard (Recommended)${NC}"
  configure_standard
  ;;
3)
  echo -e "${GREEN}Selected: Full${NC}"
  configure_full
  ;;
4)
  echo -e "${GREEN}Selected: Custom${NC}"
  configure_custom
  ;;
esac

show_configuration

read -p "Proceed with build? (y/n) [y]: " confirm
confirm=${confirm:-y}

if [[ "$confirm" =~ ^[Yy] ]]; then
  build_image
else
  echo -e "${YELLOW}Build cancelled.${NC}"
  exit 0
fi
