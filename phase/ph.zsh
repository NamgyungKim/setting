#!/bin/bash

set -euo pipefail

# 원래 프로젝트 디렉토리 (setenv.zsh 위치)
SCRIPT_DIR="/Users/gimnamgyeong/knk/1_KYLab/api-specs"


run_phase() {
	if ! command -v phase >/dev/null 2>&1; then
		echo "phase CLI를 찾을 수 없습니다." >&2
		exit 1
	fi

	command phase "$@"
}

handle_secrets_export() {
	if ! command -v phase >/dev/null 2>&1; then
		echo "phase CLI를 찾을 수 없습니다." >&2
		exit 1
	fi

	local temp_output temp_result temp_imported
	temp_output=$(mktemp)
	temp_result=$(mktemp)
	temp_imported=$(mktemp)

	# phase secrets export 실행
	command phase secrets export "$@" > "$temp_output"

	# 단계 1: 원본 파일의 변수들을 처리 (플레이스홀더 확인)
	while IFS='=' read -r key value; do
		# 빈 줄이나 주석 무시
		[[ -z "$key" || "$key" =~ ^# ]] && {
			echo "$key${value:+=$value}" >> "$temp_result"
			continue
		}

		# 값의 양쪽 따옴표 제거
		value="${value%\"}"
		value="${value#\"}"

		# ${app::env} 형식의 플레이스홀더 감지
		if [[ "$value" =~ ^\$\{([^:}]+)::([^.}]+)(\.)?\[^}]*\}$ ]]; then
			local app_name="${BASH_REMATCH[1]}"
			local env_name="${BASH_REMATCH[2]}"


			# 플레이스홀더 대신에 해당 앱/환경의 변수들을 임시파일에 저장
			command phase secrets export --app "$app_name" --env "$env_name" 2>/dev/null >> "$temp_imported"
			continue
		fi

		# ${env} 형식의 플레이스홀더 감지 (app 없음)
		if [[ "$value" =~ ^\$\{([^:}]+)\}$ ]]; then
			local env_name="${BASH_REMATCH[1]}"


			# app 없이 env만으로 요청
			command phase secrets export --env "$env_name" 2>/dev/null >> "$temp_imported"
			continue
		fi

		# 일반 변수는 그대로 출력
		echo "$key=\"$value\"" >> "$temp_result"
	done < "$temp_output"

	# 단계 2: 임포트된 변수들 중에서 중복된 것 제외
	while IFS='=' read -r imported_key imported_value; do
		[[ -z "$imported_key" || "$imported_key" =~ ^# ]] && continue

		# 원본 파일에 이미 있는 변수는 건너뛰기
		if grep -q "^${imported_key}=" "$temp_result" 2>/dev/null; then
			continue
		fi

		# 새로운 변수만 추가
		echo "$imported_key=$imported_value" >> "$temp_result"
	done < "$temp_imported"

	# 결과 출력
	cat "$temp_result"

	rm -f "$temp_output" "$temp_result" "$temp_imported"
}

run_custom_command() {
	local command_name="$1"
	shift || true

	case "$command_name" in
		setenv|sync-env)
			"$SCRIPT_DIR/setenv.zsh" "$@"
			;;
		secrets)
			if [[ "${1:-}" == "export" ]]; then
				shift
				handle_secrets_export "$@"
			else
				run_phase "secrets" "$@"
			fi
			;;
		*)
			run_phase "$command_name" "$@"
			;;
	esac
}

if [[ $# -eq 0 ]]; then
	run_phase
fi

run_custom_command "$@"
