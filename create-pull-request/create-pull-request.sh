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

# Create PR if one isn't already open for this branch
pr_state=$(gh pr view "$INPUT_BRANCH" --json state --jq '.state' 2>/dev/null || echo "")
if [ "$pr_state" != "OPEN" ]; then
  gh pr create \
    --base "$base" \
    --head "$INPUT_BRANCH" \
    --title "$INPUT_TITLE" \
    --body "$INPUT_BODY"
fi

# Set outputs (works whether PR was just created or already existed)
pr_url=$(gh pr view "$INPUT_BRANCH" --json url --jq '.url')
pr_number=$(gh pr view "$INPUT_BRANCH" --json number --jq '.number')
echo "pull-request-url=${pr_url}" >> "$GITHUB_OUTPUT"
echo "pull-request-number=${pr_number}" >> "$GITHUB_OUTPUT"
