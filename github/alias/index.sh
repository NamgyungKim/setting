#!/bin/bash

# gh alias 등록
if [ "${REMOTE:-false}" = true ]; then
  _tmpdir="$(mktemp -d)"
  trap 'rm -rf "$_tmpdir"' EXIT
  curl -fsSL "$BASE_URL/lib/register-aliases.sh" -o "$_tmpdir/register-aliases.sh"
  # shellcheck disable=SC1090
  source "$_tmpdir/register-aliases.sh"
  register_aliases_remote "$BASE_URL/github/alias" co issue-branch issue-table pr-check pr-merge
else
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

  LIB_FILE="$ROOT_DIR/lib/register-aliases.sh"

  if [ ! -f "$LIB_FILE" ]; then
    echo "❌ Missing lib file: $LIB_FILE" >&2
    exit 1
  fi

  # shellcheck disable=SC1090
  source "$LIB_FILE"
  register_aliases "$SCRIPT_DIR"
fi

echo "✅ All gh aliases registered"

# shell alias를 ~/.zshrc에 추가
ALIASES=(
  "alias gis='gh issue-branch'"
  "alias gist='gh issue-table'"
  "alias gpr='gh pr-check'"
  "alias gprt='gh pr-table'"
  "alias gprm='gh pr-merge'"
)

set_global_aliases "${ALIASES[@]}"

echo "✅ Shell aliases configured in ~/.zshrc"
