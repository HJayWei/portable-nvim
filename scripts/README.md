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

**Usage:**

```bash
# Make executable (first time only)
chmod +x scripts/docker-run.sh

# Build and run (recommended)
./scripts/docker-run.sh run

# Only build
./scripts/docker-run.sh build

# Force rebuild and run
./scripts/docker-run.sh rebuild

# Clean everything (WARNING: deletes all data)
./scripts/docker-run.sh clean

# Show help
./scripts/docker-run.sh help
```

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
| Recommended for | Long-running dev | Quick sessions |

**Choose docker-compose if:**
- You want to run container in background
- You prefer declarative configuration
- You work with multiple services

**Choose docker-run.sh if:**
- You want automatic cleanup
- You prefer a single command
- You want quick, disposable sessions

---

## Examples

### Quick Start with docker-run.sh
```bash
# First time setup
chmod +x scripts/docker-run.sh
./scripts/docker-run.sh run

# Opens Neovim container directly
# Exit with Ctrl+D or 'exit'
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
