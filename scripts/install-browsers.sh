#!/bin/sh

# Install web browsers and browser tools.
# Uses fzf for interactive multi-select.

ITEMS=(
  "Brave|https://brave.com/|Web browser focusing on privacy"
  "BrowserOS|https://www.browseros.com/|Open-source agentic browser"
  "Google Chrome|https://www.google.com.au/chrome/|Web browser"
  "Microsoft Edge|https://www.microsoft.com/en-us/edge|Web browser"
  "Responsively|https://responsively.app/|Modified browser for responsive web development"
  "Firefox|https://www.firefox.com/|Web browser"
  "Firefox Nightly|https://www.firefox.com/|Nightly builds"
  "Zen Browser|https://zen-browser.app/|Dual and quad pane browsing"
  "Browserino|https://github.com/AlexStrNik/Browserino|Browser selector for macOS, choose which app opens each link"
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
  --prompt 'Browsers> ' \
  --reverse) || true

if [ -z "$SELECTED" ]; then
  echo "Skipping browsers."
else
  echo "Installing browsers..."
  echo "$SELECTED" | while IFS='|' read -r name url desc; do
    case "$name" in
      "Brave") echo "  Installing Brave..."; brew install --cask brave-browser || echo "    Failed" ;;
      "BrowserOS") echo "  Installing BrowserOS..."; brew install --cask browseros || echo "    Failed" ;;
      "Google Chrome") echo "  Installing Google Chrome..."; brew install --cask google-chrome || echo "    Failed" ;;
      "Microsoft Edge") echo "  Installing Microsoft Edge..."; brew install --cask microsoft-edge || echo "    Failed" ;;
      "Responsively") echo "  Installing Responsively..."; brew install --cask responsively || echo "    Failed" ;;
      "Firefox") echo "  Installing Firefox..."; brew install --cask firefox || echo "    Failed" ;;
      "Firefox Nightly") echo "  Installing Firefox Nightly..."; brew install --cask firefox@nightly || echo "    Failed" ;;
      "Zen Browser") echo "  Installing Zen Browser..."; brew install --cask zen || echo "    Failed" ;;
      "Browserino") echo "  Installing Browserino..."; brew install AlexStrNik/Browserino/browserino || echo "    Failed" ;;
    esac
  done
fi

echo "Browsers done!"
