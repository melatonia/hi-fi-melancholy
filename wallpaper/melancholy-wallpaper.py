#!/usr/bin/env python3
import os
import sys

from ImageGoNord import GoNord
from PIL import Image, ImageEnhance

# ── Melancholy Palettes ──────────────────────────────────────────────────────
PAL_MORNING = [
    "#f5f0e8",
    "#ede7db",
    "#e2ddd4",
    "#d4cec4",
    "#c2bcb2",
    "#28241e",
    "#5a5248",
    "#625c56",
    "#c4601a",
    "#8a4418",
    "#f5d9c8",
    "#e8a882",
    "#5c2c0e",
    "#1e4a6a",
    "#3a7ca8",
    "#2a5230",
    "#4e8c5a",
    "#5c4220",
    "#8a6a3a",
]
PAL_NIGHT = [
    "#16130f",
    "#1e1b16",
    "#26231d",
    "#2e2a24",
    "#3a352e",
    "#f0ebe2",
    "#b8b2a8",
    "#908a82",
    "#e8844a",
    "#3a1e0a",
    "#6a3418",
    "#c46030",
    "#f0a870",
    "#9ec4d8",
    "#78b4d4",
    "#a8d8b0",
    "#7ec48a",
    "#e8c898",
    "#d4a870",
]


def apply_melancholy_pro(input_path, palette, output_path, mode="morning"):
    go_nord = GoNord()
    go_nord.reset_palette()
    for color in palette:
        go_nord.add_color_to_palette(color)

    # Load image
    img = Image.open(input_path).convert("RGB")

    # ── OPTIMIZATION: Mode-Specific Pre-Processing ──
    if mode == "night":
        # Soften shadows to use more mid-tone browns (Prevents harshness)
        img = ImageEnhance.Contrast(img).enhance(0.85)
    else:
        # Boost Morning contrast slightly so 'Parchment' doesn't look like 'Gray'
        img = ImageEnhance.Contrast(img).enhance(1.1)
        # Subtle saturation boost helps the denim blues and oranges pop
        img = ImageEnhance.Color(img).enhance(1.1)

    # Core GoNord conversion
    result = go_nord.convert_image(img)

    result.save(output_path, quality=95)
    print(f"  ✓ Created: {output_path}")


def main():
    if len(sys.argv) < 2:
        return

    input_path = sys.argv[1]
    base = os.path.splitext(input_path)[0]

    print("── Melancholy System: Writing Wallpapers ──")

    # Morning: Soft, paper-like, tactile
    apply_melancholy_pro(input_path, PAL_MORNING, f"{base}-morning.png", mode="morning")

    # Night: Deep, moody, low-contrast
    apply_melancholy_pro(input_path, PAL_NIGHT, f"{base}-night.png", mode="night")


if __name__ == "__main__":
    main()
