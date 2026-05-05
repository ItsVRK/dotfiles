#!/bin/sh

# macOS system tweaks — apply or revert Desktop, Dock, and Finder settings.
# Prompted by the setup orchestrator.



CHOICE=$(printf '%s\n' "Apply" "Undo" "Skip" | fzf \
  --header='Apply or undo macOS system tweaks?' \
  --prompt='System Tweaks> ' \
  --reverse \
  --height=7 \
  --no-multi) || true

case "$CHOICE" in
    Apply)
        echo "Applying system tweaks..."

        # --- Desktop tweaks ---
        echo "  Desktop: disable displays have separate Spaces"
        defaults write com.apple.spaces "spans-displays" -bool "false"
        killall SystemUIServer

        # --- Dock tweaks ---
        echo "  Dock: autohide, instant hide, larger tiles, no recents, no MRU spaces"
        defaults write com.apple.dock "autohide" -bool "true"
        defaults write com.apple.dock "autohide-time-modifier" -float "0"
        defaults write com.apple.dock "tilesize" -int "64"
        defaults write com.apple.dock "show-recents" -bool "false"
        defaults write com.apple.dock "mru-spaces" -bool "false"
        killall Dock

        # --- Finder tweaks ---
        echo "  Finder: Show extensions, Show hidden files, Show path bar, Default view style as list, Keep folders on top, Default save location disk instead of iCloud, Toolbar title rollover delay fast, Sidebar icon size small"
        defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
        defaults write com.apple.finder "AppleShowAllFiles" -bool "true"
        defaults write com.apple.finder "ShowPathbar" -bool "true"
        defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv"
        defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"
        defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool "false"
        defaults write NSGlobalDomain "NSToolbarTitleViewRolloverDelay" -float "0"
        defaults write NSGlobalDomain "NSTableViewDefaultSizeMode" -int "1"
        killall Finder

        # --- Remove default Dock icons ---
        if command -v brew >/dev/null 2>&1; then
            echo "  Dock: removing default dock icons..."
            brew install dockutil
            dockutil --remove all
            brew uninstall dockutil
        else
            echo "  Dock: skipping dock icon removal (brew not available yet)"
        fi

        echo "System tweaks applied!"
        ;;
    Undo)
        echo "Reverting system tweaks to defaults..."

        # --- Revert Desktop tweaks ---
        echo "  Desktop: restore displays have separate Spaces"
        defaults write com.apple.spaces "spans-displays" -bool "true"
        killall SystemUIServer

        # --- Revert Dock tweaks ---
        echo "  Dock: restore defaults"
        defaults write com.apple.dock "autohide" -bool "false"
        defaults write com.apple.dock "autohide-time-modifier" -float "0.2"
        defaults write com.apple.dock "tilesize" -int "48"
        defaults write com.apple.dock "show-recents" -bool "true"
        defaults write com.apple.dock "mru-spaces" -bool "true"
        killall Dock

        # --- Revert Finder tweaks ---
        echo "  Finder: restoring defaults"
        defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "false"
        defaults write com.apple.finder "AppleShowAllFiles" -bool "false"
        defaults write com.apple.finder "ShowPathbar" -bool "false"
        defaults write com.apple.finder "FXPreferredViewStyle" -string "icnv"
        defaults write com.apple.finder "_FXSortFoldersFirst" -bool "false"
        defaults write NSGlobalDomain "NSDocumentSaveNewDocumentsToCloud" -bool "true"
        defaults delete NSGlobalDomain "NSToolbarTitleViewRolloverDelay" 2>/dev/null || true
        defaults delete NSGlobalDomain "NSTableViewDefaultSizeMode" 2>/dev/null || true
        killall Finder

        # --- Note: Dock icons ---
        echo "  Note: default Dock icons were removed during setup and cannot be automatically restored."
        echo "  Drag apps back to the Dock manually, or run: defaults delete com.apple.dock; killall Dock"
        echo "  (warning: that resets all Dock preferences)"

        echo "System tweaks reverted to defaults!"
        ;;
    *)
        echo "Skipping system tweaks."
        ;;
esac
