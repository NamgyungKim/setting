#!/bin/bash
# gh alias: co
# Usage: gh co <PR_NUMBER>
# Description: Checkout a pull request locally

gh alias delete co 2>/dev/null
gh alias set co 'pr checkout'
