#!/usr/bin/env bash

if [ "${REMOTE:-false}" = true ]; then
	bash <(curl -fsSL "$BASE_URL/github/alias/index.sh")
else
	SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
	bash "$SCRIPT_DIR/alias/index.sh"
fi