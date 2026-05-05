#!/bin/sh

# Install maker/hardware tools: 3D printing, CAD, electronics.
# Uses fzf for interactive multi-select.

ITEMS=(
  "Arduino IDE|https://www.arduino.cc/en/software|Electronics prototyping platform"
  "Bambu Connect|https://wiki.bambulab.com/en/software/bambu-connect|Tool for linking with Bambu Lab 3D printers"
  "Bambu Studio|https://bambulab.com/en/download/studio|3D model slicing software for 3D printers"
  "FreeCAD|https://www.freecad.org/|Your own 3D parametric modeler"
  "KiCad|https://kicad.org/|Electronics design automation suite"
  "ThumbHost3mf|https://github.com/DavidPhillipOster/ThumbHost3mf/|Finder thumbnail provider for .gcode, .bgcode and .3mf files"
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
  --prompt 'Making Tools> ' \
  --reverse) || true

if [ -z "$SELECTED" ]; then
  echo "Skipping making tools."
else
  echo "Installing making tools..."
  TMPFILE=$(mktemp)
  echo "$SELECTED" > "$TMPFILE"
  while IFS='|' read -r name _url _desc <&3; do
    case "$name" in
      "Arduino IDE") echo "  Installing Arduino IDE..."; brew install --cask arduino-ide || echo "    Failed" ;;
      "Bambu Connect") echo "  Installing Bambu Connect..."; brew install --cask bambu-connect || echo "    Failed" ;;
      "Bambu Studio") echo "  Installing Bambu Studio..."; brew install --cask bambu-studio || echo "    Failed" ;;
      "FreeCAD") echo "  Installing FreeCAD..."; brew install --cask freecad || echo "    Failed" ;;
      "KiCad") echo "  Installing KiCad..."; brew install --cask kicad || echo "    Failed" ;;
      "ThumbHost3mf") echo "  Installing ThumbHost3mf..."; brew install --cask thumbhost3mf || echo "    Failed" ;;
    esac
  done 3< "$TMPFILE"
  rm -f "$TMPFILE"
fi

echo "Making tools done!"
