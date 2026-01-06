#!/bin/bash

# gh alias 등록
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for f in "$SCRIPT_DIR"/*.sh; do
  [ "$(basename "$f")" = "main.sh" ] && continue
  bash "$f"
done

echo "✅ All gh aliases registered"

# shell alias를 ~/.zshrc에 추가
ALIASES=(
  "alias gis='gh issue-branch'"
  "alias gist='gh issue-table'"
  "alias gpr='gh pr-check'"
  "alias gprt='gh pr-table'"
  "alias gprm='gh pr-merge'"
)

for a in "${ALIASES[@]}"; do
  if ! grep -qF "$a" ~/.zshrc 2>/dev/null; then
    echo "$a" >> ~/.zshrc
    echo "Added: $a"
  fi
done

echo "✅ Shell aliases configured in ~/.zshrc"
