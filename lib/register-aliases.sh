#!/bin/bash
 
register_aliases() {
  local script_dir="$1"

  find "$script_dir" -maxdepth 1 -type f -name "*.sh" -print0 | while IFS= read -r -d '' file; do
    [ "$(basename "$file")" = "index.sh" ] && continue

    local name="${file##*/}"
    name="${name%.sh}"
    local content
    content=$(cat "$file")
    printf "Setting up gh alias: %s\n" "$name"
    
    gh alias delete "$name" &>/dev/null
    gh alias set "$name" &>/dev/null '!{
      '"$content"'
    }; f "$@"'
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