#!/bin/bash
# gh alias: pr-check
# Usage: gh pr-check
# Description: Push current branch, create PR, and check CI status

gh alias delete pr-check &>/dev/null
gh alias set pr-check &>/dev/null '!f() {
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

  # base 브랜치 존재 확인
  if ! git rev-parse --verify "origin/$base" >/dev/null 2>&1; then
    echo "❌ Branch '\''$base'\'' does not exist."
    return 1
  fi

  # head 브랜치 입력 (기본값: $CURRENT_BRANCH)
  read -p "Enter head branch (default: $CURRENT_BRANCH): " head
  head=${head:-$CURRENT_BRANCH}

  # head 브랜치 존재 확인
  if ! git rev-parse --verify "$head" >/dev/null 2>&1; then
    echo "❌ Branch '\''$head'\'' does not exist."
    return 1
  fi

  # 브랜치명에서 이슈 번호 추출 (예: User/3 → 3)
  ISSUE=$(echo "$BRANCH" | awk -F/ '\''NF>1 && $NF ~ /^[0-9]+$/ {print $NF}'\'')

  # 임시 파일 생성
  TMPFILE=$(mktemp)

  # 템플릿 작성
  CLOSE_LINE=""
  [ -n "$ISSUE" ] && CLOSE_LINE="Closes #$ISSUE"

  cat > "$TMPFILE" << EOF
// PR: $head -> $base
// 첫 번째 줄: PR 제목 (필수)
// 세 번째 줄부터: PR 본문 (선택)
// //으로 시작하는 줄은 무시됩니다
// :wq 저장 :q! 종료
// -------------------------------------------------


$CLOSE_LINE
EOF

  # 수정 시간 기록
  BEFORE=$(stat -f %m "$TMPFILE")

  # 에디터 열기 (마지막에서 2번째 줄에서 시작)
  ${EDITOR:-vim} "+\$-2" "$TMPFILE"

  # 저장 여부 확인
  AFTER=$(stat -f %m "$TMPFILE")
  if [ "$BEFORE" = "$AFTER" ]; then
    echo "❌ Cancelled."
    rm "$TMPFILE"
    return 1
  fi

  # 제목 추출 (// 주석 제외한 첫 번째 비어있지 않은 줄)
  title=$(grep -v "^[[:space:]]*//" "$TMPFILE" | grep -v "^[[:space:]]*$" | head -1)

  # 본문 추출 (제목 제외한 나머지)
  body=$(grep -v "^[[:space:]]*//" "$TMPFILE" | tail -n +2)

  rm "$TMPFILE"

  if [ -z "$title" ]; then
    echo "❌ Title cannot be empty."
    return 1
  fi

  if [ -n "$ISSUE" ]; then
    echo "Detected issue from branch name: #$ISSUE"
  fi

  # PR 생성 및 본인 assignee 지정
  echo "Creating PR: $title"
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
}; f "$@"'
