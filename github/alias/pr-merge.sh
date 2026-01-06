#!/bin/bash
# gh alias: pr-merge
# Usage: gh pr-merge <PR_NUMBER>
# Description: Merge a PR with selected merge method

gh alias set pr-merge '!f() {
  PR="$1"

  if [ -z "$PR" ]; then
    echo "❌ Provide a PR number. Usage: gh pr-merge <PR_NUMBER>"
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

  # PR 정보 가져오기
  BASE=$(gh pr view "$PR" --json baseRefName --jq ".baseRefName")
  HEAD=$(gh pr view "$PR" --json headRefName --jq ".headRefName")

  echo "Merging PR #$PR ($HEAD -> $BASE) with $METHOD..."
  gh pr merge "$PR" $MERGE_FLAG --delete-branch

  echo "✅ PR #$PR merged successfully"
}; f'
