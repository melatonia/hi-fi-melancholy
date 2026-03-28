# Melancholy — Wallpaper Converter

Converts any image to the Melancholy color palette.
Outputs two variants in one run — light (Parchment · Morning) and dark (Void · Night).

## Requirements

- Python 3.8+
- Internet connection for first-time setup

## Setup (once)

```bash
chmod +x setup.sh convert.sh
./setup.sh
```

## Usage

```bash
./convert.sh path/to/your/wallpaper.jpg
```

**Output:**
```
path/to/your/wallpaper-melancholy-light.png
path/to/your/wallpaper-melancholy-dark.png
```

Both files land next to the original. Done.

## How it works

Uses [ImageGoNord](https://github.com/Schroedinger-Hat/ImageGoNord-pip) to remap
every pixel to the nearest color in the Melancholy palette. The palette is defined
in `melancholy-wallpaper.py` and mirrors `melancholy-colors.css` exactly.

Light and dark palettes are applied separately, giving you a morning and night
variant of the same image — ready for your time-based toggle.

## Palette source

`melancholy-colors.css` — do not edit the palette here without updating that file too.
