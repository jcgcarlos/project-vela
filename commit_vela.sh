#!/bin/bash

# ----------------------------------------
# Project Vela Commit Script
# Run after every work session: bash commit_vela.sh
# ----------------------------------------

REPO_PATH="/Users/jc/Projects/project-vela"
cd "$REPO_PATH"

# Check if there's anything to commit
if [ -z "$(git status --porcelain)" ]; then
  echo "Nothing to commit. No changes detected."
  exit 0
fi

# Stage all changes
git add .

# Get a summary of what changed
DIFF_STAT=$(git diff --staged --stat)
DIFF_DETAIL=$(git diff --staged --name-only)

echo "Changed files:"
echo "$DIFF_DETAIL"
echo ""

# ----------------------------------------
# GENERATE COMMIT MESSAGE
# ----------------------------------------

# Filter to core deliverables — SQL files, markdown findings, notebooks, Python scripts
DELIVERABLE_FILES=$(echo "$DIFF_DETAIL" | grep -E "\.(sql|md|py|ipynb)$" | grep -v "README.md" | grep -v "commit_vela.sh" || true)

# If there are deliverable files, get their diff for context
if [ -n "$DELIVERABLE_FILES" ]; then
  DELIVERABLE_DIFF=$(git diff --staged -- $DELIVERABLE_FILES | head -500)
else
  DELIVERABLE_DIFF=""
fi

COMMIT_MSG=$(claude -p "You are writing a Git commit message for JC's portfolio project: Project Vela — a synthetic B2B fintech analytics case study. JC is a BI Specialist transitioning to a Senior Data Analyst role in fintech, SaaS, or e-commerce.

Project Vela has three phases:
- Phase 1: SQL Analysis (tracks: feature adoption, transaction behavior, churn signals, KYC progression, north star synthesis)
- Phase 2: Python EDA
- Phase 3: ML Churn Model

Here are ALL files changed this session:
$DIFF_DETAIL

Here are the core deliverable files only (SQL, Python, notebooks, findings docs):
$DELIVERABLE_FILES

Here is the diff of the deliverable files:
$DELIVERABLE_DIFF

Write a Git commit message with:
- Subject line: max 50 chars. Name the HYPOTHESIS or BUSINESS QUESTION being tested — not the method or grouping. Bad: 'Add feature adoption SQL - activation by segment'. Good: 'Feature adoption: does depth predict transaction value?'
- Body: 3 lines max.
  Line 1: what the output actually reveals in business terms — what can a stakeholder decide or conclude from this?
  Line 2: what pattern, signal, or risk this surfaces (connect to retention, revenue, churn, or growth where relevant).
  Line 3: what this finding sets up or enables next — show forward thinking, not task completion.

IMPORTANT: This is portfolio work. Commit messages will be read by recruiters and senior analysts. Never describe the SQL mechanics (CTEs, joins, aggregations) — describe the analytical value. Frame it like someone who owns the insight, not someone who wrote the query. Do NOT mention README updates, script changes, or folder structure changes.

If only non-deliverable files changed (scripts, config, README), write a short housekeeping commit message instead.

Voice: direct, no fluff, no corporate language, no emojis, lowercase where it feels natural. Reads like a sharp analyst, not a changelog.

Output the commit message only. Nothing else. No explanation.")

echo "Proposed commit message:"
echo "---"
echo "$COMMIT_MSG"
echo "---"
echo ""

# Ask for confirmation before committing
read -p "Commit with this message? (y/n): " CONFIRM

if [ "$CONFIRM" = "y" ]; then
  git commit -m "$COMMIT_MSG"
  git push origin main
  echo ""
  echo "Done. Committed and pushed."
else
  echo "Cancelled. Nothing committed."
  git reset HEAD .
fi