#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
	exec /usr/bin/env bash "$0" "$@"
fi

set -euo pipefail

# 실행 방식 감지: 로컬 파일 직접 실행 vs curl -fsSL | bash
_src="${BASH_SOURCE[0]:-$0}"
if [[ "$_src" != /dev/fd/* ]] && [[ "$_src" != "bash" ]] && [ -f "$_src" ]; then
	export BASE_URL="$(cd "$(dirname "$_src")" && pwd)"
	export REMOTE=false
else
	export BASE_URL="https://raw.githubusercontent.com/NamgyungKim/setting/main"
	export REMOTE=true
fi

LIB_CHECKBOX="$BASE_URL/lib/checkbox.sh"

if [ "$REMOTE" = true ]; then
	# shellcheck disable=SC1090
	source <(curl -fsSL "$LIB_CHECKBOX")
else
	if [ ! -f "$LIB_CHECKBOX" ]; then
		echo "❌ Missing lib file: $LIB_CHECKBOX" >&2
		exit 1
	fi
	# shellcheck disable=SC1090
	source "$LIB_CHECKBOX"
fi

selected=$(radio_select "Select items" "brew" "git" "gitHub" | head -n 1)

script="$BASE_URL/$selected/index.sh"
if [ "$REMOTE" = true ]; then
	echo "➡️  Executing: $script"
	bash <(curl -fsSL "$script")
else
	if [ -f "$script" ]; then
		echo "➡️  Executing: $script"
		sh "$script"
	else
		echo "❌ Script not found: $script" >&2
	fi
fi
