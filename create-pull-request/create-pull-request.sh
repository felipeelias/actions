#!/usr/bin/env bash
set -euo pipefail

# Required: INPUT_BRANCH, INPUT_TITLE
# Optional: INPUT_COMMIT_MESSAGE (defaults to INPUT_TITLE), INPUT_BODY, INPUT_ADD (defaults to "."), INPUT_BASE

commit_message="${INPUT_COMMIT_MESSAGE:-$INPUT_TITLE}"
add_patterns="${INPUT_ADD:-.}"

# Configure git identity
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

# Record base branch before switching
base="${INPUT_BASE:-$(git branch --show-current)}"

# Stage files and check for changes
# shellcheck disable=SC2086
git add $add_patterns
if git diff --cached --quiet; then
  echo "No changes to commit"
  exit 0
fi

# Create branch (idempotent), commit, push
git checkout -B "$INPUT_BRANCH"
git commit -m "$commit_message"
git push --force origin "$INPUT_BRANCH"

# Debug: show what token gh is using
gh auth status 2>&1 || true

# Create PR if one isn't already open for this branch
pr_number=$(gh pr list --head "$INPUT_BRANCH" --state open --json number --jq '.[0].number // empty' 2>/dev/null || echo "")
if [ -z "$pr_number" ]; then
  pr_url=$(gh api "repos/${GITHUB_REPOSITORY}/pulls" \
    --method POST \
    -f title="$INPUT_TITLE" \
    -f body="$INPUT_BODY" \
    -f head="$INPUT_BRANCH" \
    -f base="$base" \
    --jq '.html_url')
  pr_number=$(gh pr view "$INPUT_BRANCH" --json number --jq '.number')
fi

# Set outputs (works whether PR was just created or already existed)
pr_url="${pr_url:-$(gh pr view "$INPUT_BRANCH" --json url --jq '.url')}"
echo "pull-request-url=${pr_url}" >> "$GITHUB_OUTPUT"
echo "pull-request-number=${pr_number}" >> "$GITHUB_OUTPUT"
