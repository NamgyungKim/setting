#!/bin/bash

register_aliases_remote() {
  local base_url="$1"
  shift
  local names=("$@")

  for name in "${names[@]}"; do
    local content
    content=$(curl -fsSL "$base_url/$name.sh")
    printf "Setting up gh alias: %s\n" "$name"
    gh alias delete "$name" &>/dev/null || true
    gh alias set "$name" '!f() {
      '"$content"'
}; f "$@"' &>/dev/null
  done
}

register_aliases() {
  local script_dir="$1"

  find "$script_dir" -maxdepth 1 -type f -name "*.sh" -print0 | while IFS= read -r -d '' file; do
    [ "$(basename "$file")" = "index.sh" ] && continue

    local name="${file##*/}"
    name="${name%.sh}"
    local content
    content=$(cat "$file")
    printf "Setting up gh alias: %s\n" "$name"
    
    gh alias delete "$name" &>/dev/null || true
    gh alias set "$name" '!f() {
      '"$content"'
}; f "$@"' &>/dev/null
  done
}

set_global_aliases() {
  local aliases=("$@")

  for a in "${aliases[@]}"; do
    if ! grep -qF "$a" ~/.zshrc 2>/dev/null; then
      echo "$a" >> ~/.zshrc
      echo "Added: $a"
    fi
  done 
}