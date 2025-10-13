# 🚀 Portable Neovim - Docker Edition

A portable Neovim development environment based on Docker, allowing you to use the same Neovim configuration across any platform.

> **📝 Important Note**: Place your Neovim configuration in the `config/nvim/` directory, which maps to `~/.config/nvim/` inside the container.

## ✨ Features

- 🐋 **Fully Containerized**: Stable environment based on Debian
- 🎨 **Custom Configuration**: Use your own Neovim configuration
- 🛠️ **Rich Toolchain**: Includes Git, ripgrep, fzf, and other development tools
- 💾 **Persistent Support**: Plugins and configurations are automatically saved
- 🌐 **Multi-Language Support**: Python, JavaScript/TypeScript, Go, Lua, and more

## 📋 Prerequisites

- Docker (20.10+)
- Docker Compose (optional, recommended)

## 🚀 Quick Start

### Using Docker Compose

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
│   └── entrypoint.sh     # Container startup script
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

Edit your `config/nvim/` configuration files (e.g., `lua/plugins.lua`) and add the required Language Servers in your Mason LSP configuration.

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

### Programming Languages
- Python 3 (with pip)
- Node.js (with npm)
- Go
- Rust
- PHP

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
