#!/bin/sh

# Replace the bootstrapped chezmoi binary with the Homebrew-managed version.

set -e

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Skipping chezmoi cleanup."
    exit 0
fi

BREW_CHEZMOI="$(brew --prefix)/bin/chezmoi"
if [ ! -f "$BREW_CHEZMOI" ]; then
    echo "Installing chezmoi via Homebrew..."
    brew install chezmoi
fi

if [ -f "${HOME}/bin/chezmoi" ]; then
    echo "Removing bootstrapped chezmoi (~/bin/chezmoi)..."
    rm -f "${HOME}/bin/chezmoi"

    # Clean up ~/bin if it's now empty
    if [ -d "${HOME}/bin" ] && [ -z "$(ls -A "${HOME}/bin")" ]; then
        echo "Removing empty ~/bin directory..."
        rmdir "${HOME}/bin"
    fi

    echo "Using Homebrew-managed chezmoi at ${BREW_CHEZMOI}"
else
    echo "No bootstrapped chezmoi to clean up."
fi
