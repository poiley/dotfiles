#!/usr/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  Dotfiles Setup Script${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Function to print status messages
info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Homebrew if not present
if ! command_exists brew; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    info "✓ Homebrew already installed"
fi

# Update Homebrew
info "Updating Homebrew..."
brew update

# Install core requirements
info "Installing core packages..."
CORE_PACKAGES=(
    "antidote"      # Fast plugin manager
    "neofetch"      # System info display
    "gh"            # GitHub CLI
)

for package in "${CORE_PACKAGES[@]}"; do
    if brew list "$package" &>/dev/null; then
        info "✓ $package already installed"
    else
        info "Installing $package..."
        brew install "$package"
    fi
done

# Install optional development tools
info "Installing optional development tools..."
OPTIONAL_PACKAGES=(
    "mise"          # Runtime version manager (rust-based, faster than asdf)
    "pyenv"         # Python version manager
    "bun"           # Fast JavaScript runtime
    "trufflehog"    # Secret scanning
    "pre-commit"    # Git hooks framework
)

for package in "${OPTIONAL_PACKAGES[@]}"; do
    if brew list "$package" &>/dev/null; then
        info "✓ $package already installed"
    else
        info "Installing $package..."
        brew install "$package"
    fi
done

# Get the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "Dotfiles directory: $DOTFILES_DIR"

# Backup existing configs
backup_file() {
    local file="$1"
    if [[ -f "$file" ]] && [[ ! -L "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        info "Backing up $file to $backup"
        mv "$file" "$backup"
    fi
}

# Create symlinks
create_symlink() {
    local src="$1"
    local dest="$2"

    if [[ -L "$dest" ]]; then
        # Already a symlink, check if it points to our file
        if [[ "$(readlink "$dest")" == "$src" ]]; then
            info "✓ $dest already linked correctly"
            return
        else
            warn "$dest is a symlink to $(readlink "$dest"), updating..."
            rm "$dest"
        fi
    elif [[ -f "$dest" ]]; then
        backup_file "$dest"
    fi

    info "Linking $dest -> $src"
    ln -s "$src" "$dest"
}

# Link config files
info "Setting up config file symlinks..."
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"
create_symlink "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

# Link .alias if it exists
if [[ -f "$DOTFILES_DIR/.alias" ]]; then
    create_symlink "$DOTFILES_DIR/.alias" "$HOME/.alias"
fi

# Initialize antidote plugins
info "Initializing antidote plugins..."
if [[ ! -f "$HOME/.zsh_plugins.zsh" ]]; then
    info "Generating static plugin file..."
    antidote bundle <"$HOME/.zsh_plugins.txt" >| "$HOME/.zsh_plugins.zsh"
else
    info "✓ Plugin file already exists"
fi

# Set up pre-commit hooks in dotfiles repo
if [[ -f "$DOTFILES_DIR/.pre-commit-config.yaml" ]]; then
    info "Setting up pre-commit hooks..."
    cd "$DOTFILES_DIR"
    pre-commit install
    cd - >/dev/null
fi

# Check for .env file
info "Checking environment setup..."
if [[ ! -f "$HOME/.env" ]]; then
    warn "~/.env not found"
    warn "Create ~/.env with your API keys and environment variables"
    warn "This file is gitignored and should contain sensitive data"

    # Create empty .env as template
    touch "$HOME/.env"
    info "Created empty ~/.env file"
else
    info "✓ ~/.env exists"
fi

# Final steps
echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
info "Next steps:"
echo "  1. Add your API keys to ~/.env"
echo "  2. Restart your shell: exec zsh"
echo "  3. On first run, antidote will clone plugins (takes a few seconds)"
echo ""
info "Your shell startup should be ~315ms with centered neofetch"
info "Core startup (without neofetch) is ~65ms"
echo ""
