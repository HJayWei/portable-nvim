#!/bin/bash
# ============================================================================
# Portable Neovim Docker Container Entrypoint Script
# ============================================================================

set -e

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}  Portable Neovim Development Container  ${NC}"
echo -e "${BLUE}==========================================${NC}"

# Check Neovim configuration directory
if [ ! -d "${NVIM_CONFIG_DIR}" ]; then
    echo -e "${YELLOW}Warning: Neovim configuration directory does not exist, creating...${NC}"
    mkdir -p "${NVIM_CONFIG_DIR}"
fi

# Auto-install plugins on first startup
if [ ! -d "${NVIM_DATA_DIR}/lazy" ]; then
    echo -e "${GREEN}First startup, installing Neovim plugins...${NC}"
    echo -e "${YELLOW}This may take some time, please wait...${NC}"
    
    # Silent plugin installation
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    
    echo -e "${GREEN}Plugin installation complete!${NC}"
fi

# Display welcome message
echo -e "${GREEN}✓ Neovim configuration loaded${NC}"
echo -e "${GREEN}✓ Working directory: /workspace${NC}"
echo ""
echo -e "Use ${BLUE}nvim${NC} command to start Neovim"
echo -e "Use ${BLUE}exit${NC} command to exit container"
echo ""

# Execute passed command, default is zsh
exec "$@"
