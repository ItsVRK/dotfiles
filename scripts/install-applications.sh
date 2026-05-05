#!/bin/sh

# Install desktop applications.
# Uses fzf for interactive multi-select.

ITEMS=(
  "1Password|https://1password.com/|Securely store, generate, and autofill passwords"
  "Affinity Studio|https://www.affinity.studio/|Professional design, photo editing, and page layout"
  "Alfred|https://www.alfredapp.com/|Productivity app for macOS"
  "AnyDesk|https://anydesk.com/|Remote desktop control"
  "Araxis Merge|https://www.araxis.com/merge/|Two and three-way file comparison and merging"
  "Balsamiq Wireframes|https://balsamiq.com/|UI wireframing tool"
  "BetterTouchTool|https://folivora.ai/|Customize various input devices on your Mac"
  "Beyond Compare|https://www.scootersoftware.com/|Compare files and folders"
  "Cardhop|https://flexibits.com/cardhop|Menu bar contacts manager"
  "Chipmunk|https://github.com/esrlabs/chipmunk/|Log analysis tool"
  "Cyberduck|https://cyberduck.io/|Server and cloud storage browser (FTP, etc)"
  "Discord|https://discord.com/|Voice and text chat"
  "Docker Desktop|https://www.docker.com/products/docker-desktop/|Containerization software for developers"
  "Ferdium|https://ferdium.org/|Multi-platform multi-messaging app"
  "Ghostty|https://ghostty.org/|Fast, feature-rich terminal emulator with GPU acceleration"
  "Git Tower|https://www.git-tower.com|Mac git client"
  "IINA|https://iina.io/|Free and open-source media player"
  "Karabiner Elements|https://karabiner-elements.pqrs.org/|Keyboard customiser"
  "KeyCastr|https://github.com/keycastr/keycastr|Open-source keystroke visualiser"
  "Krita|https://krita.org/en/|Free painting and sketching program"
  "Obsidian|https://obsidian.md/|Knowledge base on local Markdown files"
  "Pearcleaner|https://itsalin.com/appInfo/?id=pearcleaner|Mac app uninstaller"
  "ScreenKite|https://www.screenkite.com/|macOS screen recorder and video editor for AI agents"
  "There|https://there.pm/|Display local times of friends and time zones"
  "TRex|https://ameba.co/trex/|Copy text from screen/clipboard including images"
  "UTM|https://mac.getutm.app/|Virtual machines for Mac using QEMU"
  "VS Code|https://code.visualstudio.com/|Code editor"
  "Yaak|https://yaak.app/|Modern, secure, offline API client (Postman alt)"
  "Objective-See tools|https://objective-see.org|Free macOS security tools (LuLu, BlockBlock, KnockKnock, DHS)"
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
  --prompt 'Applications> ' \
  --reverse) || true

if [ -z "$SELECTED" ]; then
  echo "Skipping applications."
else
  echo "Installing applications..."
  TMPFILE=$(mktemp)
  echo "$SELECTED" > "$TMPFILE"
  while IFS='|' read -r name _url _desc <&3; do
    case "$name" in
      "1Password") echo "  Installing 1Password..."; brew install --cask 1password || echo "    Failed" ;;
      "Affinity Studio") echo "  Installing Affinity Studio..."; brew install --cask affinity || echo "    Failed" ;;
      "Alfred") echo "  Installing Alfred..."; brew install --cask alfred || echo "    Failed" ;;
      "AnyDesk") echo "  Installing AnyDesk..."; brew install --cask anydesk || echo "    Failed" ;;
      "Araxis Merge") echo "  Installing Araxis Merge..."; brew install --cask araxis-merge || echo "    Failed" ;;
      "Balsamiq Wireframes") echo "  Installing Balsamiq Wireframes..."; brew install --cask balsamiq-wireframes || echo "    Failed" ;;
      "BetterTouchTool") echo "  Installing BetterTouchTool..."; brew install --cask bettertouchtool || echo "    Failed" ;;
      "Beyond Compare") echo "  Installing Beyond Compare..."; brew install --cask beyond-compare || echo "    Failed" ;;
      "Calendar-366") echo "  Installing Calendar-366..."; brew install --cask calendar-366 || echo "    Failed" ;;
      "Cardhop") echo "  Installing Cardhop..."; brew install --cask cardhop || echo "    Failed" ;;
      "Chipmunk") echo "  Installing Chipmunk..."; brew install --cask chipmunk || echo "    Failed" ;;
      "Cyberduck") echo "  Installing Cyberduck..."; brew install --cask cyberduck || echo "    Failed" ;;
      "Discord") echo "  Installing Discord..."; brew install --cask discord || echo "    Failed" ;;
      "Docker Desktop") echo "  Installing Docker Desktop..."; brew install docker-desktop || echo "    Failed" ;;
      "Ferdium") echo "  Installing Ferdium..."; brew install --cask ferdium || echo "    Failed" ;;
      "Ghostty") echo "  Installing Ghostty..."; brew install --cask ghostty || echo "    Failed" ;;
      "Git Tower") echo "  Installing Git Tower..."; brew install tower || echo "    Failed" ;;
      "IINA") echo "  Installing IINA..."; brew install --cask iina || echo "    Failed" ;;
      "Karabiner Elements") echo "  Installing Karabiner Elements..."; brew install --cask karabiner-elements || echo "    Failed" ;;
      "KeyCastr") echo "  Installing KeyCastr..."; brew install --cask keycastr || echo "    Failed" ;;
      "Krita") echo "  Installing Krita..."; brew install --cask krita || echo "    Failed" ;;
      "Obsidian") echo "  Installing Obsidian..."; brew install --cask obsidian || echo "    Failed" ;;
      "Pearcleaner") echo "  Installing Pearcleaner..."; brew install --cask pearcleaner || echo "    Failed" ;;
      "ScreenKite") echo "  Installing ScreenKite..."; brew install --cask screenkite || echo "    Failed" ;;
      "There") echo "  Installing There..."; brew install --cask there || echo "    Failed" ;;
      "TRex") echo "  Installing TRex..."; brew install --cask trex || echo "    Failed" ;;
      "UTM") echo "  Installing UTM..."; brew install --cask utm || echo "    Failed" ;;
      "VS Code")
        echo "  Installing VS Code..."
        brew install visual-studio-code || echo "    Failed"
        sh "${HOME}/.local/share/chezmoi/scripts/install-vscode-extensions.sh"
        ;;
      "Yaak") echo "  Installing Yaak..."; brew install --cask yaak || echo "    Failed" ;;
    esac
  done 3< "$TMPFILE"
  rm -f "$TMPFILE"

  # Install Objective-See tools last so firewall doesn't block earlier installs
  if echo "$SELECTED" | grep -q "^Objective-See tools|" || echo "$SELECTED" | grep -q "\nObjective-See tools|"; then
    echo ""
    echo "  Installing Objective-See tools (LuLu, BlockBlock, KnockKnock, DHS)..."
    brew install --cask lulu blockblock knockknock dhs || echo "    Failed"
    echo ""
    echo "⚠ LuLu was installed. Please open it from Applications and approve the network extension."
    echo "  This is required before any app can access the network."
    printf "  Press Enter when done... "
    read -r
  fi
fi

echo "Applications done!"
