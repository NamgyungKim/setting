#!/bin/bash
# gh alias: issue-table
# Usage: gh issue-table
# Description: Display open issues in a formatted table

gh alias delete issue-table 2>/dev/null
gh alias set issue-table '!{
printf "ID\tTITLE\tASSIGNEE\tLABELS\tSTATE\tURL\n"
gh issue list --state open \
  --json number,title,assignees,labels,state,url \
  --jq ".[] | [
    \"#\"+(.number|tostring),
    .title,
    (if (.assignees | length == 0) then \"-\" else (.assignees | map(.login) | join(\",\")) end),
    (if (.labels | length == 0) then \"-\" else (.labels | map(.name) | join(\",\")) end),
    .state,
    .url
  ] | @tsv" \
| column -t
}'
