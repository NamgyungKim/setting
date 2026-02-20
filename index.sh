#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
	exec /usr/bin/env bash "$0" "$@"
fi

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_CHECKBOX="$SCRIPT_DIR/lib/checkbox.sh"
echo $SCRIPT_DIR
echo $LIB_CHECKBOX

if [ ! -f "$LIB_CHECKBOX" ]; then
	echo "❌ Missing lib file: $LIB_CHECKBOX" >&2
	exit 1
fi

# shellcheck disable=SC1090
source "$LIB_CHECKBOX"

selected=$(radio_select "Select items" "brew" "git" "gitHub" | head -n 1)

script="$SCRIPT_DIR/$selected/index.sh"
if [ -f "$script" ]; then
  echo "➡️  Executing: $script"
  sh "$script"
else
  echo "❌ Script not found: $script" >&2
fi
