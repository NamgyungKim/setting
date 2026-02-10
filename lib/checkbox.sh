#!/usr/bin/env bash

# Usage:
#   selected=$(checkbox_select "Select items" "apple" "banana" "cherry")
#   echo "$selected"
# Returns selected items as newline-separated text.

checkbox_select() {
	local prompt="${1:-Select options}"
	shift || true
	local options=("$@")

	if [ "${#options[@]}" -eq 0 ]; then
		return 1
	fi

	local count=${#options[@]}
	local -a chosen
	local cursor=0
	local key

	for ((i=0; i<count; i++)); do
		chosen[i]=0
	done

	_render() {
		printf '\033[H\033[J' >&2
		echo "$prompt" >&2
		echo "(↑/↓ 이동, Space 선택, Enter 확정)" >&2
		for ((i=0; i<count; i++)); do
			local mark="[ ]"
			[ "${chosen[i]}" -eq 1 ] && mark="[x]"
			if [ "$i" -eq "$cursor" ]; then
				printf "> %s %s\n" "$mark" "${options[i]}" >&2
			else
				printf "  %s %s\n" "$mark" "${options[i]}" >&2
			fi
		done
	}

	_render
	while IFS= read -rsn1 key; do
		case "$key" in
			$'\x1b')
				read -rsn2 key
				case "$key" in
					"[A") cursor=$(( (cursor - 1 + count) % count )) ;; # up
					"[B") cursor=$(( (cursor + 1) % count )) ;;       # down
					esac
				;;
			" ")
				if [ "${chosen[cursor]}" -eq 1 ]; then
					chosen[cursor]=0
				else
					chosen[cursor]=1
				fi
				;;
			""|$'\n'|$'\r')
				break
				;;
		esac
		_render
	done

	printf '\033[H\033[J' >&2
	for ((i=0; i<count; i++)); do
		if [ "${chosen[i]}" -eq 1 ]; then
			printf '%s\n' "${options[i]}"
		fi
	done
}

radio_select() {
	local prompt="${1:-Select one}"
	shift || true
	local options=("$@")

	if [ "${#options[@]}" -eq 0 ]; then
		return 1
	fi

	local count=${#options[@]}
	local cursor=0
	local selected=0
	local key

	_render() {
		printf '\033[H\033[J' >&2
		echo "$prompt" >&2
		echo "(↑/↓ 이동, Space 선택, Enter 확정)" >&2
		for ((i=0; i<count; i++)); do
			local mark="○"
			[ "$i" -eq "$selected" ] && mark="●"
			if [ "$i" -eq "$cursor" ]; then
				printf "> %s %s\n" "$mark" "${options[i]}" >&2
			else
				printf "  %s %s\n" "$mark" "${options[i]}" >&2
			fi
		done
	}

	_render
	while IFS= read -rsn1 key; do
		case "$key" in
			$'\x1b')
				read -rsn2 key
				case "$key" in
					"[A") cursor=$(( (cursor - 1 + count) % count )) ;; # up
					"[B") cursor=$(( (cursor + 1) % count )) ;;       # down
					esac
				;;
			" ")
				selected=$cursor
				;;
			""|$'\n'|$'\r')
				break
				;;
		esac
		_render
	done

	printf '\033[H\033[J' >&2
	printf '%s\n' "${options[selected]}"
}
 
 