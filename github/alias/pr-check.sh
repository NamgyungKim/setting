#!/bin/bash
# gh alias: pr-check
# Usage: gh pr-check
# Description: Push current branch, create PR, and check CI status

gh alias delete pr-check 2>/dev/null
gh alias set pr-check '!f() {
  # 현재 브랜치 push
  BRANCH=$(git symbolic-ref --short HEAD)
  echo "Pushing current branch: $BRANCH..."
  git push -u origin "$BRANCH" || return 1

  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
	# base 브랜치 입력 (기본값: develop, 단 현재 브랜치가 develop이면 main)
	if [ "$CURRENT_BRANCH" = "develop" ]; then
	  default_base="main"
	else
	  default_base="develop"
	fi

	read -p "Enter base branch (default: $default_base): " base
	base=${base:-$default_base}

  # head 브랜치 입력 (기본값: $CURRENT_BRANCH)
  read -p "Enter head branch (default: $CURRENT_BRANCH): " head
  head=${head:-$CURRENT_BRANCH}

  # PR 제목 입력
  read -p "Enter PR title: " title
  [ -z "$title" ] && echo "Title cannot be empty." && return 1

  # PR 본문 입력 (선택)
  read -p "Enter PR body (optional): " body

  # 브랜치명에서 이슈 번호 추출 (예: User/3 → 3)
  ISSUE=$(echo "$BRANCH" | awk -F/ '\''NF>1 && $NF ~ /^[0-9]+$/ {print $NF}'\'')

  # 이슈 번호가 있으면 body 맨 아래에 Closes #추가
  if [ -n "$ISSUE" ]; then
    body="$body

Closes #$ISSUE"
    echo "Detected issue from branch name: #$ISSUE"
  fi

  # PR 생성 및 본인 assignee 지정
  echo "Creating PR and assigning to @me..."
  PR_URL=$(gh pr create \
    --title "$title" \
    --body "$body" \
    --assignee "@me" \
    --base "$base" \
    --head "$head"
  ) || return 1

  # PR 번호 추출
  PR_NUMBER=$(echo "$PR_URL" | sed "s|.*/||")
  echo "✅ PR #$PR_NUMBER created: $PR_URL"

  # CI / 체크 상태 출력
  echo "Checking CI/CD status..."
  gh pr checks "$PR_NUMBER"

  # PR URL 출력
  echo "$PR_URL"
}; f'
