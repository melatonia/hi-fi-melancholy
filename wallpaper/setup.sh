#!/usr/bin/env bash
# setup.sh — one-time setup for melancholy wallpaper tools
# Run this once from the tools/wallpaper directory.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"

echo ""
echo "Melancholy — Wallpaper Tool Setup"
echo ""

# Check python
if ! command -v python3 &>/dev/null; then
    echo "Error: python3 not found. Install it with: sudo pacman -S python"
    exit 1
fi

# Create venv
echo "→ Creating virtual environment..."
python3 -m venv "$VENV_DIR"

# Install dependencies
echo "→ Installing image-go-nord and Pillow..."
"$VENV_DIR/bin/pip" install --quiet --upgrade pip
"$VENV_DIR/bin/pip" install --quiet image-go-nord Pillow

echo ""
echo "✓ Setup complete."
echo ""
echo "Usage:"
echo "  ./convert.sh <path/to/wallpaper.jpg>"
echo ""
