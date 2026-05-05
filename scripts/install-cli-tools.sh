#!/bin/sh

# Install developer CLI tools and global packages.
# Uses fzf for interactive multi-select.

ITEMS=(
  "1Password CLI|https://developer.1password.com/docs/cli/|Command-line interface for 1Password (op)"
  "Atuin|https://atuin.sh/|Shell history"
  "DDEV|https://ddev.com/|Docker based PHP development environments"
  "Git|https://git-scm.com/|Version control"
  "Lagoon CLI|https://uselagoon.github.io/lagoon-cli/|CLI tool for amazee hosting"
  "Mise|https://mise.jdx.dev/|Polyglot tool version manager (replaces asdf, nvm, pyenv, etc.)"
  "Opencode|https://opencode.ai/|AI coding agent for terminal"
  "Pi|https://pi.dev|AI coding agent harness (via npm)"
  "Safehouse|https://agent-safehouse.dev/|macOS-native sandboxing for local agents"
  "Starling|https://github.com/Ryandonofrio3/Starling|Local only AI Voice-to-Text & Paste"
  "Starship|https://starship.rs/|Minimal, blazing-fast, and infinitely customizable prompt"
  "SwiftLint|https://github.com/realm/SwiftLint|Tool to enforce Swift style and conventions (requires Xcode)"
)

echo ""

SELECTED=$(printf '%s\n' "${ITEMS[@]}" | fzf --multi \
  --bind 'load:select-all' \
  --bind 'space:toggle' \
  --delimiter='|' \
  --with-nth=1 \
  --header='✓ = selected for install · ↑↓ navigate · space/tab toggle · enter confirm · esc skip' \
  --marker='✓' \
  --pointer='►' \
  --preview='echo "{3}" && echo "" && echo "{2}"' \
  --preview-window='up,3,wrap' \
  --prompt 'CLI Tools> ' \
  --reverse) || true

if [ -z "$SELECTED" ]; then
  echo "Skipping CLI tools."
else
  echo "Installing CLI tools..."
  TMPFILE=$(mktemp)
  printf '%s\n' "$SELECTED" > "$TMPFILE"
  while IFS='|' read -r name rest <&3; do
    case "$name" in
      "1Password CLI") echo "  Installing 1Password CLI..."; brew install 1password-cli || echo "    Failed" ;;
      "Atuin") echo "  Installing Atuin..."; brew install atuin || echo "    Failed" ;;
      "DDEV") echo "  Installing DDEV..."; brew install ddev/ddev/ddev || echo "    Failed" ;;
      "Git") echo "  Installing Git..."; brew install git || echo "    Failed" ;;
      "Lagoon CLI") echo "  Installing Lagoon CLI..."; brew install uselagoon/lagoon-cli/lagoon || echo "    Failed" ;;
      "Mise") echo "  Installing Mise..."; brew install mise || echo "    Failed" ;;
      "Opencode") echo "  Installing Opencode..."; brew install anomalyco/tap/opencode || echo "    Failed" ;;
      "Safehouse") echo "  Installing Safehouse..."; brew install eugene1g/safehouse/agent-safehouse || echo "    Failed" ;;
      "Starling") echo "  Installing Starling..."; brew install Ryandonofrio3/starling/starling || echo "    Failed" ;;
      "Starship") echo "  Installing Starship..."; brew install starship || echo "    Failed" ;;
      "SwiftLint")
        echo "  Installing SwiftLint..."
        if xcode-select -p >/dev/null 2>&1; then
          brew install swiftlint || echo "    Failed"
        else
          echo "    Skipping SwiftLint (requires Xcode)"
        fi
        ;;
      "Pi")
        echo "  Installing Pi..."
        mise use -g node@lts
        export PATH="${HOME}/.local/share/mise/shims:${PATH}"
        mise doctor
        npm install -g @mariozechner/pi-coding-agent
        ;;
    esac
  done 3< "$TMPFILE"
  rm -f "$TMPFILE"
fi

echo "CLI tools done!"
