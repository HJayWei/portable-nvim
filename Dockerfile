# Portable Neovim Docker Image
# Stable Neovim development environment based on Debian

FROM debian:bookworm-slim

# Build arguments for language support (default: all enabled)
ARG INSTALL_PYTHON="true"
ARG INSTALL_NODEJS="true"
ARG INSTALL_GO="true"
ARG INSTALL_RUST="true"
ARG INSTALL_PHP="true"
ARG INSTALL_LUA="true"
ARG INSTALL_RSYNC="false"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color \
    NVIM_CONFIG_DIR=/root/.config/nvim \
    NVIM_DATA_DIR=/root/.local/share/nvim

# Install essential packages and tools (use --no-install-recommends to reduce size)
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Basic tools
    curl \
    wget \
    git \
    unzip \
    tar \
    gzip \
    ca-certificates \
    build-essential \
    # Development tools
    ripgrep \
    fd-find \
    fzf \
    # Conditional language packages
    $([ "$INSTALL_PYTHON" = "true" ] && echo "python3 python3-pip python3-venv" || echo "") \
    $([ "$INSTALL_NODEJS" = "true" ] && echo "nodejs npm" || echo "") \
    $([ "$INSTALL_LUA" = "true" ] && echo "lua5.3 luarocks" || echo "") \
    $([ "$INSTALL_PHP" = "true" ] && echo "php-cli php-mbstring php-xml php-curl" || echo "") \
    $([ "$INSTALL_RSYNC" = "true" ] && echo "rsync" || echo "") \
    # Terminal tools
    zsh \
    tmux \
    # Display
    locales \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install all tools and dependencies in a single layer to reduce image size
RUN ARCH=$(uname -m) && \
    # Detect architecture
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
        NVIM_ARCH="arm64"; \
        LAZYGIT_ARCH="arm64"; \
    elif [ "$ARCH" = "x86_64" ]; then \
        NVIM_ARCH="x64"; \
        LAZYGIT_ARCH="x86_64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    \
    # Install Neovim
    wget -q https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz && \
    tar -xzf nvim-linux-${NVIM_ARCH}.tar.gz && \
    mv nvim-linux-${NVIM_ARCH} /opt/nvim && \
    ln -s /opt/nvim/bin/nvim /usr/bin/nvim && \
    rm nvim-linux-${NVIM_ARCH}.tar.gz && \
    \
    # Install lazygit
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') && \
    curl -sLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz" && \
    tar xf lazygit.tar.gz lazygit && \
    install lazygit /usr/local/bin && \
    rm -f lazygit.tar.gz lazygit && \
    \
    # Install Composer (if PHP enabled)
    if [ "$INSTALL_PHP" = "true" ]; then \
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    fi && \
    \
    # Set locale
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && \
    \
    # Install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    \
    # Set zsh as default shell
    chsh -s $(which zsh) && \
    \
    # Install Python packages for Neovim (if Python enabled)
    if [ "$INSTALL_PYTHON" = "true" ]; then \
        pip3 install --no-cache-dir --break-system-packages \
            pynvim \
            black \
            flake8 \
            pylint \
            autopep8; \
    fi && \
    \
    # Install Node.js packages for Neovim (if Node.js enabled)
    if [ "$INSTALL_NODEJS" = "true" ]; then \
        npm install -g neovim tree-sitter-cli && \
        npm cache clean --force; \
    fi && \
    \
    # Install Go (if Go enabled)
    if [ "$INSTALL_GO" = "true" ]; then \
        GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n 1) && \
        if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
            GO_ARCH="arm64"; \
        elif [ "$ARCH" = "x86_64" ]; then \
            GO_ARCH="amd64"; \
        fi && \
        wget -q https://go.dev/dl/${GO_VERSION}.linux-${GO_ARCH}.tar.gz && \
        tar -C /usr/local -xzf ${GO_VERSION}.linux-${GO_ARCH}.tar.gz && \
        rm -f ${GO_VERSION}.linux-${GO_ARCH}.tar.gz; \
    fi && \
    \
    # Install Rust with minimal profile (if Rust enabled)
    if [ "$INSTALL_RUST" = "true" ]; then \
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --no-modify-path && \
        . "$HOME/.cargo/env" && \
        rm -rf /root/.cargo/registry/cache && \
        rm -rf /root/.cargo/registry/src && \
        rm -rf /root/.rustup/downloads && \
        rm -rf /root/.rustup/tmp; \
    fi && \
    \
    # Clean up all caches and temporary files
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /root/.cache/* && \
    rm -rf /root/.npm/_cacache 2>/dev/null || true && \
    \
    # Create necessary directories
    mkdir -p ${NVIM_CONFIG_DIR} ${NVIM_DATA_DIR} && \
    \
    # Create language support marker file for Neovim config
    echo "# Language Support Configuration" > /root/.language-support && \
    echo "PYTHON=$INSTALL_PYTHON" >> /root/.language-support && \
    echo "NODEJS=$INSTALL_NODEJS" >> /root/.language-support && \
    echo "GO=$INSTALL_GO" >> /root/.language-support && \
    echo "RUST=$INSTALL_RUST" >> /root/.language-support && \
    echo "PHP=$INSTALL_PHP" >> /root/.language-support && \
    echo "LUA=$INSTALL_LUA" >> /root/.language-support && \
    echo "RSYNC=$INSTALL_RSYNC" >> /root/.language-support

# Set Go and Rust environment variables
ENV PATH="/usr/local/go/bin:/root/.cargo/bin:${PATH}" \
    GOPATH="/root/go" \
    GOBIN="/root/go/bin"
ENV PATH="${GOBIN}:${PATH}"

# Set working directory
WORKDIR /workspace

# Copy startup script
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command: start zsh
CMD ["zsh"]
