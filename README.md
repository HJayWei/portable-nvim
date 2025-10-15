# 🚀 Portable Neovim - Docker Edition

A portable Neovim development environment based on Docker, allowing you to use the same Neovim configuration across any platform.

> **📝 Important Note**: Place your Neovim configuration in the `config/nvim/` directory, which maps to `~/.config/nvim/` inside the container.

## ✨ Features

- 🐋 **Fully Containerized**: Stable environment based on Debian
- 🎨 **Custom Configuration**: Use your own Neovim configuration
- 🛠️ **Rich Toolchain**: Includes Git, ripgrep, fzf, and other development tools
- 💾 **Persistent Support**: Plugins and configurations are automatically saved
- 🌐 **Flexible Language Support**: Choose which languages to install (Python, Node.js, Go, Rust, PHP, Lua)
- 🔍 **Smart Tool Detection**: Mason automatically installs only tools for enabled languages
- 📦 **Optimized Image Size**: Install only what you need (800MB to 2.5GB depending on configuration)

## 📋 Prerequisites

- Docker (20.10+)
- Docker Compose (optional, recommended)

## 🚀 Quick Start

> **💡 First Time Setup:** Use `build-config.sh` to choose your language support before building!

### Step 1: Configure and Build (First Time)

```bash
# Make script executable
chmod +x scripts/build-config.sh

# Run interactive configuration
./scripts/build-config.sh
```

**Choose your preset:**

- **Minimal** (~800MB-1GB): Essential tools only (Neovim, Git, lazygit, terminal tools)
- **Standard** (~1.5-1.8GB): Minimal + Python + Node.js (Recommended for most users)
- **Full** (~2-2.5GB): All languages (Python, Node.js, Go, Rust, PHP, Lua) + rsync
- **Custom**: Pick specific languages and tools (including optional rsync)

**Language Support Detection:**
The image creates a `.language-support` marker file that Neovim plugins read to conditionally install LSP servers and tools. This prevents errors when trying to install tools for languages that aren't available.

---

### Method 1: Using docker-run.sh (Recommended for Quick Sessions)

```bash
# Make script executable (first time only)
chmod +x scripts/docker-run.sh

# Build and run with default workspace (./workspace)
./scripts/docker-run.sh run

# Run with custom workspace directory
./scripts/docker-run.sh run -w ~/projects/myapp

# Force rebuild and run
./scripts/docker-run.sh rebuild

# Show all available options
./scripts/docker-run.sh help
```

**Benefits:**

- ✅ Auto-cleanup with `--rm` (container removed on exit)
- ✅ Persistent data via named volumes
- ✅ Custom workspace directory support
- ✅ Single command to build and run

### Method 2: Using Docker Compose (Recommended for Long-Running Development)

1. **Start Container**

   ```bash
   docker-compose up -d
   ```

2. **Enter Container**

   ```bash
   docker-compose exec nvim zsh
   ```

3. **Stop Container**

   ```bash
   docker-compose down
   ```

**Benefits:**

- ✅ Run in background with `-d`
- ✅ Declarative configuration
- ✅ Easy to manage multiple services

## 📂 Project Structure

```
portable-nvim/
├── Dockerfile            # Docker Image definition
├── docker-compose.yml    # Docker Compose configuration
├── .dockerignore         # Docker ignore file
├── README.md             # Project documentation
├── config/               # Configuration directory (maps to ~/.config in container)
│   └── nvim/             # Neovim configuration directory
│       ├── init.lua      # Neovim main configuration
│       └── lua/          # Lua configuration modules
│           ├── ...       # Your custom configuration
├── scripts/              # Utility scripts
│   ├── docker-run.sh     # Standalone Docker management script
│   ├── entrypoint.sh     # Container startup script
│   └── README.md         # Scripts documentation
└── workspace/            # Working directory (mount point)
```

## ⌨️ Common Keybindings

### Leader Key

- **Leader Key**: `Space`

### Basic Operations

- `<C-w>` - Save file
- `<C-q>` - Quit

### File Operations

- `<leader>e` - Toggle file explorer
- `<leader>ff` - Find files
- `<leader>fg` - Global search
- `<leader>fb` - Search buffers
- `<leader>fh` - Search help

### Window Operations

- `<C-h/j/k/l>` - Navigate windows
- `<leader>v` - Vertical split
- `<leader>h` - Horizontal split

### LSP Operations

- `gd` - Go to definition
- `K` - Show documentation
- `gi` - Go to implementation

### Terminal

- `<C-\>` - Toggle floating terminal
- `<Esc>` - Exit terminal mode

### Other

- `s` - Flash quick jump
- `gcc` - Toggle line comment
- `gc` - Toggle block comment (visual mode)

## 🔧 Custom Configuration

### Modify Neovim Configuration

1. Place your Neovim configuration in the `config/nvim/` directory
2. Rebuild the Docker Image

**Note**: The `config/` directory maps to `/root/.config/` inside the container, so you can place any `.config` configuration files here.

### Add Language Support

The configuration automatically detects available languages via the `.language-support` marker file:

1. **Rebuild with desired languages**: Run `./scripts/build-config.sh` and select languages
2. **Automatic tool installation**: Mason will only attempt to install tools for enabled languages
3. **Manual override**: Edit `config/nvim/lua/plugins/mason-tool-installer.lua` if needed

**How it works:**

- During Docker build, a marker file is created at `~/.language-support`
- `lua/utils/language-support.lua` reads this file
- Plugins like `mason-tool-installer.lua` and `rsync.lua` check language availability
- Only tools for enabled languages are installed, preventing errors

## 🎯 Use Cases

1. **Cross-Platform Development**: Use the same configuration on macOS, Linux, and Windows
2. **Team Collaboration**: Ensure all team members use a consistent development environment
3. **CI/CD Integration**: Use the same editing environment in CI pipelines
4. **Temporary Environment**: Quickly set up a clean development environment
5. **Version Isolation**: Use different tool versions for different projects

## 📦 Included Tools

### Development Tools

- Neovim
- Git
- ripgrep
- fd
- fzf

### Programming Languages (Optional)

All languages are **optional** and can be selected during build configuration:

- **Python 3** (with pip, pynvim, black, flake8, pylint, autopep8)
- **Node.js** (with npm, neovim support, tree-sitter-cli)
- **Go** (latest stable version from official source, not Debian repos)
- **Rust** (via rustup, minimal profile)
- **PHP** (with Composer)
- **Lua** (5.3 with LuaRocks)

**Additional Tools:**

- **rsync** (optional, enables rsync.nvim plugin for remote file sync)

### Terminal Tools

- zsh (default shell)
- oh-my-zsh
- tmux

### Neovim Plugins

Depends on your `config/nvim/` configuration. Common plugins include:

- **Plugin Manager**: Lazy.nvim
- **File Manager**: nvim-tree or neo-tree
- **Fuzzy Finder**: Telescope
- **Syntax Highlighting**: Treesitter
- **LSP**: nvim-lspconfig + Mason
- **Completion**: nvim-cmp
- **Status Line**: lualine
- **Git Integration**: gitsigns
- **More**: See your configuration files

## 🔄 Updates & Maintenance

### Update Plugins

Run inside the container:

```vim
:Lazy sync
```

### Clean Unused Docker Resources

```bash
docker system prune -a
```

## 📄 License

MIT License

## 🙏 Acknowledgments

Thanks to all Neovim plugin developers and community contributors.
