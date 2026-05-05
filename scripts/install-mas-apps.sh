#!/bin/sh

# Install mas (Mac App Store CLI) and Mac App Store applications.
# Uses fzf for interactive multi-select.
# Run after Homebrew is installed.

# Install mas if not present
if ! command -v mas >/dev/null 2>&1; then
    echo "Installing mas (Mac App Store CLI)..."
    brew install mas
fi

# name|mas ID|description
ITEMS=(
  "1Password for Safari|1569813296|Safari extension for 1Password"
  "Calendar 366 II|1265895169|Menubar Calendar Management"
  "Menubar Meeting|6752535574|Meeting tracker in menu bar"
  "Monosnap|540348655|Screenshot tool"
  "Paprika Recipe Manager 3|1303222628|Recipe manager"
  "Quick Camera|598853070|Quick access to camera"
  "Sequel Ace|1518036000|MySQL/MariaDB database client"
  "Side Mirror|944860108|Sidecar helper"
  "Xcode|497799835|Apple IDE (required for SwiftLint)"
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
  --preview='echo "{3}" && echo "" && echo "mas ID: {2}"' \
  --preview-window='up,3,wrap' \
  --prompt 'Mac App Store> ' \
  --reverse) || true

if [ -z "$SELECTED" ]; then
  echo "Skipping Mac App Store apps."
else
  echo "Installing Mac App Store apps..."
  TMPFILE=$(mktemp)
  echo "$SELECTED" > "$TMPFILE"
  while IFS='|' read -r name id _desc <&3; do
    if mas list | grep -q "^${id}"; then
      echo "  Already installed: ${name}"
    else
      echo "  Installing ${name} (${id})..."
      mas install "$id" || echo "    Failed to install ${name}"
      # Signal to orchestrator that Xcode was freshly installed
      if [ "$id" = "497799835" ]; then
        touch "${HOME}/.setup-xcode-installed"
      fi
    fi
  done 3< "$TMPFILE"
  rm -f "$TMPFILE"
fi

echo "Mac App Store apps done!"
