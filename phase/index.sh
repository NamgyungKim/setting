#!/usr/bin/env bash

echo "🚀 Starting setup for ph command"

if [ "${REMOTE:-false}" = true ]; then
  bash <(curl -fsSL "$BASE_URL/git/alias/index.sh")
  curl -fsSL "$BASE_URL/phase/ph.zsh" -o /tmp/ph.zsh
  mv /tmp/ph.zsh ~/.local/bin/ph
  chmod +x ~/.local/bin/ph
else
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)" 
  cp "$SCRIPT_DIR/ph.zsh" ~/.local/bin/ph
  chmod +x ~/.local/bin/ph
fi

echo "✅ ph command setup complete. You can now use 'ph' in your terminal."