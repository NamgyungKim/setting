#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_FILE="$ROOT_DIR/lib/register-aliases.sh"

if [ ! -f "$LIB_FILE" ]; then
  echo "❌ Missing lib file: $LIB_FILE" >&2
  exit 1
fi
 
source "$LIB_FILE"

# shell alias를 ~/.zshrc에 추가
ALIASES=(
  "alias ghist='git hist'" 
  "alias gca='git commit --amend --no-edit'" 
)

set_global_aliases "${ALIASES[@]}"

echo "✅ Shell aliases configured in ~/.zshrc"