#!/bin/bash
# gh alias: issue-branch
# Usage: gh issue-branch
# Description: Create a new issue and checkout to a branch named after it

gh alias delete issue-branch 2>/dev/null
gh alias set issue-branch '!f() {
  # 이슈 제목 입력
  read -p "Enter issue title: " title
  if [ -z "$title" ]; then
    echo "Title cannot be empty."
    return 1
  fi

  # 이슈 본문 입력 (선택 사항)
  read -p "Enter issue body (optional): " body

  # 이슈 생성 및 자기 자신에게 할당
  echo "Creating issue and assigning to @me..."
  ISSUE_URL=$(gh issue create --title "$title" --body "$body" --assignee "@me")

  # 실패 시 종료
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
  
  # 완료 메시지 출력
  echo ""
  echo "✅ Issue #${ISSUE_NUMBER} created: $ISSUE_URL"
  echo "✅ Switched to new branch: $BRANCH_NAME"
  echo "$ISSUE_URL"
}; f'
