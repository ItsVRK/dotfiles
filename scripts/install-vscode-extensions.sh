#!/usr/bin/env bash
# Install VS Code extensions
set -euo pipefail

extensions=(
  bmewburn.vscode-intelephense-client
  bradlc.vscode-tailwindcss
  codeviz.codeviz
  davidanson.vscode-markdownlint
  dbaeumer.vscode-eslint
  editorconfig.editorconfig
  gruntfuggly.todo-tree
  hverlin.mise-vscode
  llvm-vs-code-extensions.lldb-dap
  mhutchie.git-graph
  ms-azuretools.vscode-containers
  ms-vscode-remote.remote-containers
  ms-vscode-remote.remote-ssh
  ms-vscode.cpptools
  nuxtr.nuxtr-vscode
  pkief.material-icon-theme
  platformio.platformio-ide
  redhat.vscode-yaml
  redhat.vscode-xml
  sst-dev.opencode
  streetsidesoftware.code-spell-checker
  stylelint.vscode-stylelint
  swiftlang.swift-vscode
  tamasfe.even-better-toml
  theumletteam.umlet
  trybick.terminal-zoom
  valeryanm.vscode-phpsab
  vue.volar
  waderyan.gitblame
  xdebug.php-debug
)

echo "Installing extensions..."
echo "⚠ If LuLu (or another firewall) is running, make sure to allow VS Code network access when prompted."
echo ""

for ext in "${extensions[@]}"; do
  code --install-extension "$ext" || echo "  Failed to install ${ext}"
done

echo ""
echo "Done! Installed ${#extensions[@]} extensions."

echo ""
echo "Removing copilot chat extension..."
code --force --uninstall-extension github.copilot-chat 2>/dev/null || true
