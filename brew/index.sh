#!/usr/bin/env bash

set -euo pipefail

if command -v brew >/dev/null 2>&1; then
	echo "✅ Homebrew already installed: $(brew --version | head -1)"
	exit 0
fi

echo "Homebrew not found. Installing..."

if ! command -v curl >/dev/null 2>&1; then
	echo "❌ curl is required to install Homebrew." >&2
	exit 1
fi

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if command -v brew >/dev/null 2>&1; then
	echo "✅ Homebrew installed successfully."
else
	echo "❌ Homebrew installation did not complete." >&2
	exit 1
fi

