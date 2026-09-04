#!/bin/bash

set -e

# === Sozlamalar ===
NERD_FONT_NAME="JetBrainsMono"
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${NERD_FONT_NAME}.zip"
EMOJI_FONT_URL="https://raw.githubusercontent.com/googlefonts/noto-emoji/main/fonts/NotoColorEmoji.ttf"
FONT_DIR="$HOME/.local/share/fonts"
TMP_DIR="/tmp/fonts-install"

# === Tayyorlov ===
mkdir -p "$FONT_DIR"
mkdir -p "$TMP_DIR"

# === Nerd Font yuklash ===
echo "🔤 Yuklab olinmoqda: $NERD_FONT_NAME..."
wget -O "$TMP_DIR/${NERD_FONT_NAME}.zip" "$NERD_FONT_URL"

echo "📦 Ochilmoqda: $NERD_FONT_NAME..."
unzip -o "$TMP_DIR/${NERD_FONT_NAME}.zip" -d "$FONT_DIR"

# === Emoji Font yuklash (endi to'g'ridan-to'g'ri .ttf, zip emas) ===
echo "😊 Yuklab olinmoqda: Noto Color Emoji..."
wget -O "$FONT_DIR/NotoColorEmoji.ttf" "$EMOJI_FONT_URL"

# === Font cache yangilash ===
echo "🔄 Font cache yangilanmoqda..."
fc-cache -f "$FONT_DIR"

# === Tozalash ===
rm -rf "$TMP_DIR"

echo "✅ Barcha fontlar o‘rnatildi va tizimga tayyor!"
