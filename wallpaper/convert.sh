#!/usr/bin/env bash
# convert.sh — convert any image to the Melancholy palette
# Usage: ./convert.sh <path/to/image>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"

if [ ! -d "$VENV_DIR" ]; then
    echo "Error: venv not found. Run ./setup.sh first."
    exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: ./convert.sh <path/to/image>"
    exit 1
fi

"$VENV_DIR/bin/python" "$SCRIPT_DIR/melancholy-wallpaper.py" "$1"
