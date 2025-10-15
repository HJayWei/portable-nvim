# Scripts Directory

Utility scripts for managing the Portable Neovim Docker environment.

## Available Scripts

### `build-config.sh`

Interactive build configuration script that allows you to choose which language support to include.

**Features:**

- Interactive preset selection (Minimal, Standard, Full, Custom)
- Selective language installation to reduce image size
- Build argument configuration
- Estimated size preview for each preset

**Presets:**

- **Minimal** (~800MB-1GB): Neovim + Git + lazygit + terminal tools
- **Standard** (~1.5-1.8GB): Minimal + Python + Node.js (Recommended)
- **Full** (~2-2.5GB): All languages (Python, Node.js, Go, Rust, PHP, Lua) + rsync
- **Custom**: Choose specific languages and optional rsync utility

**Supported Languages:**

- Python (with pip and common packages)
- Node.js (with npm and tree-sitter)
- Go (latest stable version from official source)
- Rust (via rustup with minimal profile)
- PHP (with Composer)
- Lua (5.3 with LuaRocks)
- rsync (optional utility for remote file sync)

**Usage:**

```bash
# Make executable (first time only)
chmod +x scripts/build-config.sh

# Run interactive configuration and build
./scripts/build-config.sh

# Follow the prompts to select your configuration
```

**Manual Build with Arguments:**

```bash
# Build with specific languages
docker build \
  --build-arg INSTALL_PYTHON="true" \
  --build-arg INSTALL_NODEJS="true" \
  --build-arg INSTALL_GO="false" \
  --build-arg INSTALL_RUST="false" \
  --build-arg INSTALL_PHP="false" \
  --build-arg INSTALL_LUA="false" \
  --build-arg INSTALL_RSYNC="false" \
  -t portable-nvim:latest .
```

**Language Support Detection:**

The build process creates a `.language-support` marker file that Neovim plugins use to conditionally install tools:

- Located at `~/.language-support` inside the container
- Read by `lua/utils/language-support.lua`
- Used by `mason-tool-installer.lua` to install only relevant LSP servers
- Prevents errors when tools for unavailable languages are requested

---

### `entrypoint.sh`

Container entrypoint script that runs automatically when the container starts.

**Features:**

- Creates Neovim config directory if missing
- Auto-installs plugins on first startup
- Displays welcome message

**Usage:** Automatically executed by Docker, no manual invocation needed.

---

### `docker-run.sh`

Standalone script for building and running the container without docker-compose.

**Features:**

- Auto-detects if image needs building
- Uses named volumes for persistent data (same as docker-compose)
- Auto-cleanup with `--rm` flag (container removed on exit, data persists)
- Support for SSH keys and Git config mounting
- **Custom workspace directory** support via `-w/--workspace` parameter

**Usage:**

```bash
# Make executable (first time only)
chmod +x scripts/docker-run.sh

# Build and run with default workspace (./workspace)
./scripts/docker-run.sh run

# Run with custom workspace directory
./scripts/docker-run.sh run -w ~/projects/myapp
./scripts/docker-run.sh run --workspace /path/to/project

# Only build
./scripts/docker-run.sh build

# Force rebuild and run with custom workspace
./scripts/docker-run.sh rebuild -w ~/code

# Clean everything (WARNING: deletes all data)
./scripts/docker-run.sh clean

# Show help
./scripts/docker-run.sh help
```

**Workspace Options:**

- `-w PATH` or `--workspace PATH` - Specify custom workspace directory
- Default: `./workspace` (created automatically if it doesn't exist)
- Custom workspace must exist before running (script will validate)
- Supports both absolute and relative paths

**Persistent Data:**
The script creates named volumes that persist even when using `--rm`:

- `portable-nvim_nvim-data` - Neovim plugins and cache
- `portable-nvim_nvim-state` - Neovim state files

**Volumes are compatible with docker-compose** - data is shared between both methods.

---

## Docker Compose vs docker-run.sh

| Feature | docker-compose | docker-run.sh |
|---------|---------------|---------------|
| Ease of use | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Persistent data | ✅ Yes | ✅ Yes |
| Auto-cleanup | ❌ No | ✅ Yes (`--rm`) |
| Background mode | ✅ Yes (`-d`) | ❌ No |
| Custom workspace | ❌ Edit config | ✅ Yes (`-w` flag) |
| Recommended for | Long-running dev | Quick sessions |

**Choose docker-compose if:**

- You want to run container in background
- You prefer declarative configuration
- You work with multiple services

**Choose docker-run.sh if:**

- You want automatic cleanup
- You prefer a single command
- You want quick, disposable sessions
- You need to switch between different project directories easily

**Note:** For initial setup, use `build-config.sh` to configure and build the image, then use `docker-run.sh` to run it.

---

## Examples

### Quick Start with docker-run.sh

```bash
# First time setup
chmod +x scripts/docker-run.sh

# Use default workspace (./workspace)
./scripts/docker-run.sh run

# Use custom workspace
./scripts/docker-run.sh run -w ~/my-project

# Opens Neovim container directly
# Exit with Ctrl+D or 'exit'
```

### Working with Multiple Projects

```bash
# Switch between different projects easily
./scripts/docker-run.sh run -w ~/projects/webapp
./scripts/docker-run.sh run -w ~/projects/api-server
./scripts/docker-run.sh run -w /tmp/quick-test

# Each project gets its own workspace
# But shares the same Neovim plugins and configuration
```

### Using with docker-compose

```bash
# Start in background
docker-compose up -d

# Attach to container
docker-compose exec nvim zsh

# Stop and remove
docker-compose down
```

### Cleanup Old Data

```bash
# Remove all volumes and images
./scripts/docker-run.sh clean

# Or manually with docker
docker volume rm portable-nvim_nvim-data portable-nvim_nvim-state
docker rmi portable-nvim:latest
```
