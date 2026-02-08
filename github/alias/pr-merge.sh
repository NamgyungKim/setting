#!/bin/bash
# gh alias: pr-merge
# Usage: gh pr-merge <PR_NUMBER>
# Description: Merge a PR with selected merge method

PR="$1"

if [ -z "$PR" ]; then
  echo "❌ Provide a PR number. Usage: gh pr-merge <PR_NUMBER>"
  return 1
fi

# PR 정보 가져오기
BASE=$(gh pr view "$PR" --json baseRefName --jq ".baseRefName")
HEAD=$(gh pr view "$PR" --json headRefName --jq ".headRefName")

# 푸시되지 않은 커밋 확인
UNPUSHED=$(git log "origin/$HEAD..$HEAD" --oneline 2>/dev/null)
if [ -n "$UNPUSHED" ]; then
  echo "❌ Unpushed commits on $HEAD:"
  echo "$UNPUSHED"
  return 1
fi

echo "Select merge method:"
select METHOD in squash merge rebase; do
  case "$METHOD" in
    squash) MERGE_FLAG="--squash"; break ;;
    merge)  MERGE_FLAG="--merge";  break ;;
    rebase) MERGE_FLAG="--rebase"; break ;;
    *) echo "❌ Invalid selection" ;;
  esac
done

echo "Merging PR #$PR ($HEAD -> $BASE) with $METHOD..."
gh pr merge "$PR" $MERGE_FLAG --delete-branch

echo "✅ PR #$PR merged successfully"

# 브랜치명에서 이슈 번호 추출 (예: User/issue3 → 3)
ISSUE=$(echo "$HEAD" | grep -oE 'issue[0-9]+' | sed 's/issue//')

# 이슈가 있으면 강제로 닫기
if [ -n "$ISSUE" ]; then
  echo "Closing issue #$ISSUE..."
  gh issue close "$ISSUE"
  echo "✅ Issue #$ISSUE closed"
fi

