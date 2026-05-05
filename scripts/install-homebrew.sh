#!/bin/sh

# Install Homebrew if not present, then replace bootstrapped chezmoi with the
# Homebrew-managed version.

set -e

# --- Install Homebrew if not present ---
if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for this session (Apple Silicon Macs)
    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

echo "Installing shared font dependency..."
brew install --cask font-jetbrains-mono-nerd-font

echo "Installing homebrew-cask-upgrade tap..."
brew tap buo/cask-upgrade

echo "Installing fzf (used for interactive install menus)..."
brew install fzf

echo "Homebrew ready."
