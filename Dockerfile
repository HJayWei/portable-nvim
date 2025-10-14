# Portable Neovim Docker Image
# Stable Neovim development environment based on Debian

FROM debian:bookworm-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color \
    NVIM_CONFIG_DIR=/root/.config/nvim \
    NVIM_DATA_DIR=/root/.local/share/nvim

# Install essential packages and tools
RUN apt-get update && apt-get install -y \
    # Basic tools
    curl \
    wget \
    git \
    unzip \
    tar \
    gzip \
    build-essential \
    # Development tools
    ripgrep \
    fd-find \
    fzf \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    # Language support
    golang \
    lua5.3 \
    luarocks \
    php \
    php-cli \
    php-mbstring \
    php-xml \
    php-curl \
    # Terminal tools
    zsh \
    tmux \
    rsync \
    # Fonts and display
    fontconfig \
    locales \
    # Other utilities
    tree \
    htop \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Install latest Neovim (using precompiled version, auto-detect architecture)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
        NVIM_ARCH="arm64"; \
    elif [ "$ARCH" = "x86_64" ]; then \
        NVIM_ARCH="x86_64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz && \
    tar -xzf nvim-linux-${NVIM_ARCH}.tar.gz && \
    mv nvim-linux-${NVIM_ARCH} /opt/nvim && \
    ln -s /opt/nvim/bin/nvim /usr/bin/nvim && \
    rm nvim-linux-${NVIM_ARCH}.tar.gz

# Install lazygit (auto-detect architecture)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
        LAZYGIT_ARCH="arm64"; \
    elif [ "$ARCH" = "x86_64" ]; then \
        LAZYGIT_ARCH="x86_64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz" && \
    tar xf lazygit.tar.gz lazygit && \
    install lazygit /usr/local/bin && \
    rm lazygit.tar.gz lazygit

# Install Composer (PHP package manager)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Install oh-my-zsh (optional, enhances terminal experience)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Set zsh as default shell
RUN chsh -s $(which zsh)

# Install common Neovim dependencies
RUN pip3 install --no-cache-dir --break-system-packages \
    pynvim \
    black \
    flake8 \
    pylint \
    autopep8

# Install Node.js related Neovim dependencies
RUN npm install -g neovim tree-sitter-cli

# Install Rust (non-interactive)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Set Rust environment variables
ENV PATH="/root/.cargo/bin:${PATH}"

# Set working directory
WORKDIR /workspace

# Copy startup script
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command: start zsh
CMD ["zsh"]
