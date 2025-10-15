#!/bin/bash
# ============================================================================
# Portable Neovim Docker Run Script
# Build and run the container with persistent volumes
# ============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="portable-nvim:latest"
CONTAINER_NAME="nvim-dev"
DEFAULT_WORKSPACE_DIR="$(pwd)/workspace"
WORKSPACE_DIR="${DEFAULT_WORKSPACE_DIR}"
CONFIG_DIR="$(pwd)/config"
USE_CUSTOM_WORKSPACE=false

# Named volumes for persistence (same as docker-compose)
NVIM_DATA_VOLUME="portable-nvim_nvim-data"
NVIM_STATE_VOLUME="portable-nvim_nvim-state"

# ============================================================================
# Functions
# ============================================================================

print_header() {
  echo -e "${BLUE}==========================================${NC}"
  echo -e "${BLUE}  Portable Neovim Docker Manager${NC}"
  echo -e "${BLUE}==========================================${NC}"
  echo ""
}

build_image() {
  echo -e "${GREEN}Building Docker image...${NC}"
  docker build -t ${IMAGE_NAME} .
  echo -e "${GREEN}✓ Build complete!${NC}"
  echo ""
}

create_volumes() {
  echo -e "${YELLOW}Ensuring persistent volumes exist...${NC}"

  # Create named volumes if they don't exist
  docker volume create ${NVIM_DATA_VOLUME} >/dev/null 2>&1 || true
  docker volume create ${NVIM_STATE_VOLUME} >/dev/null 2>&1 || true

  echo -e "${GREEN}✓ Volumes ready${NC}"
  echo ""
}

stop_existing_container() {
  if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}Stopping and removing existing container...${NC}"
    docker stop ${CONTAINER_NAME} >/dev/null 2>&1 || true
    docker rm ${CONTAINER_NAME} >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ Cleaned up${NC}"
    echo ""
  fi
}

run_container() {
  echo -e "${GREEN}Starting container...${NC}"
  echo -e "${BLUE}Container name: ${CONTAINER_NAME}${NC}"
  echo -e "${BLUE}Workspace: ${WORKSPACE_DIR}${NC}"
  echo ""

  # Create workspace directory only if using default path
  if [ "${USE_CUSTOM_WORKSPACE}" = false ]; then
    mkdir -p "${WORKSPACE_DIR}"
    echo -e "${YELLOW}Created default workspace directory${NC}"
  else
    # Verify custom workspace exists
    if [ ! -d "${WORKSPACE_DIR}" ]; then
      echo -e "${RED}Error: Specified workspace directory does not exist: ${WORKSPACE_DIR}${NC}"
      echo -e "${YELLOW}Please create the directory first or use default workspace${NC}"
      exit 1
    fi
    echo -e "${GREEN}✓ Using custom workspace: ${WORKSPACE_DIR}${NC}"
  fi
  echo ""

  # Run container with --rm for auto-cleanup
  # Named volumes persist even with --rm
  docker run -it --rm \
    --name ${CONTAINER_NAME} \
    -v "${WORKSPACE_DIR}:/workspace" \
    -v "${CONFIG_DIR}:/root/.config" \
    -v "${HOME}/.ssh:/root/.ssh:ro" \
    -v "${HOME}/.gitconfig:/root/.gitconfig:ro" \
    -v ${NVIM_DATA_VOLUME}:/root/.local/share/nvim \
    -v ${NVIM_STATE_VOLUME}:/root/.local/state/nvim \
    -e TERM=xterm-256color \
    -e COLORTERM=truecolor \
    ${IMAGE_NAME}
}

show_help() {
  cat <<EOF
Usage: $0 [COMMAND] [OPTIONS]

Commands:
    build       Build the Docker image
    run         Run the container (build if needed)
    rebuild     Force rebuild and run
    shell       Run container with shell access (same as run)
    clean       Remove image and volumes (WARNING: deletes all data)
    help        Show this help message

Options:
    -w, --workspace PATH    Specify custom workspace directory
                           (default: ./workspace)

Examples:
    $0 build                              # Only build the image
    $0 run                                # Use default workspace (./workspace)
    $0 run -w ~/projects/myapp            # Use custom workspace
    $0 run --workspace /path/to/project   # Use custom workspace (long form)
    $0 rebuild -w ~/code                  # Force rebuild with custom workspace
    $0 clean                              # Remove everything

Note:
- Container is removed automatically on exit (--rm flag)
- Volumes persist across container runs
- Use Ctrl+D or 'exit' to stop the container
- Custom workspace directory must exist before running
EOF
}

clean_all() {
  echo -e "${RED}WARNING: This will remove the image and ALL persistent data!${NC}"
  read -p "Are you sure? (yes/no): " confirm

  if [ "$confirm" = "yes" ]; then
    echo -e "${YELLOW}Cleaning up...${NC}"

    # Stop and remove container
    docker stop ${CONTAINER_NAME} >/dev/null 2>&1 || true
    docker rm ${CONTAINER_NAME} >/dev/null 2>&1 || true

    # Remove image
    docker rmi ${IMAGE_NAME} >/dev/null 2>&1 || true

    # Remove volumes
    docker volume rm ${NVIM_DATA_VOLUME} >/dev/null 2>&1 || true
    docker volume rm ${NVIM_STATE_VOLUME} >/dev/null 2>&1 || true

    echo -e "${GREEN}✓ Cleanup complete${NC}"
  else
    echo -e "${YELLOW}Cleanup cancelled${NC}"
  fi
}

check_image_exists() {
  docker image inspect ${IMAGE_NAME} >/dev/null 2>&1
}

# ============================================================================
# Main
# ============================================================================

print_header

# Parse arguments
COMMAND="${1:-help}"
shift || true

# Parse options
while [[ $# -gt 0 ]]; do
  case $1 in
  -w | --workspace)
    if [ -z "$2" ]; then
      echo -e "${RED}Error: --workspace requires a path argument${NC}"
      exit 1
    fi
    WORKSPACE_DIR="$(cd "$2" 2>/dev/null && pwd || echo "$2")"
    USE_CUSTOM_WORKSPACE=true
    shift 2
    ;;
  *)
    echo -e "${RED}Error: Unknown option '${1}'${NC}"
    echo ""
    show_help
    exit 1
    ;;
  esac
done

case "${COMMAND}" in
build)
  build_image
  ;;

run | shell)
  # Build if image doesn't exist
  if ! check_image_exists; then
    echo -e "${YELLOW}Image not found, building...${NC}"
    build_image
  fi

  create_volumes
  stop_existing_container
  run_container
  ;;

rebuild)
  build_image
  create_volumes
  stop_existing_container
  run_container
  ;;

clean)
  clean_all
  ;;

help | --help | -h)
  show_help
  ;;

*)
  echo -e "${RED}Error: Unknown command '${COMMAND}'${NC}"
  echo ""
  show_help
  exit 1
  ;;
esac
