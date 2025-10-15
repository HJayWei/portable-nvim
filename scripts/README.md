# Scripts Directory

Utility scripts for managing the Portable Neovim Docker environment.

## Available Scripts

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
