#!/bin/bash
# gh alias: issue-branch
# Usage: gh issue-branch
# Description: Create a new issue and checkout to a branch named after it

gh alias delete issue-branch 2>/dev/null
gh alias set issue-branch '!f() {
  # 임시 파일 생성
  TMPFILE=$(mktemp)

  # 템플릿 작성
  cat > "$TMPFILE" << EOF
# 첫 번째 줄: 이슈 제목 (필수)
# 세 번째 줄부터: 이슈 본문 (선택)
# #으로 시작하는 줄은 무시됩니다
# :wq 저장 :q! 종료

EOF

  # 에디터 열기
  ${EDITOR:-vim} "$TMPFILE"

  # 제목 추출 (# 주석 제외한 첫 번째 비어있지 않은 줄)
  title=$(grep -v "^#" "$TMPFILE" | grep -v "^$" | head -1)

  # 본문 추출 (제목 제외한 나머지)
  body=$(grep -v "^#" "$TMPFILE" | tail -n +2)

  rm "$TMPFILE"

  if [ -z "$title" ]; then
    echo "❌ Title cannot be empty."
    return 1
  fi

  # 이슈 생성 및 자기 자신에게 할당
  echo "Creating issue: $title"
  ISSUE_URL=$(gh issue create --title "$title" --body "$body" --assignee "@me")

  if [ $? -ne 0 ]; then
    echo "❌ Issue creation failed or was cancelled."
    return 1
  fi

  # 이슈 번호 추출
  ISSUE_NUMBER=$(echo "$ISSUE_URL" | sed "s|.*/||")

  # 새로운 브랜치 이름 생성
  AUTHOR=$(gh api user -q .login)
  BRANCH_NAME="$AUTHOR/$ISSUE_NUMBER"

  # 새로운 브랜치로 체크아웃
  git checkout -b "$BRANCH_NAME"

  echo ""
  echo "✅ Issue #${ISSUE_NUMBER} created: $ISSUE_URL"
  echo "✅ Switched to new branch: $BRANCH_NAME"
}; f'
