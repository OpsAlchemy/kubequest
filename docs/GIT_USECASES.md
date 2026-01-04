# Git Usecases & Scenarios

Real situations encountered in this repository with documented solutions. Future scenarios will be logged here.

---

## Usecase #1: Non-Linear Branch History (Unwanted Merge Commit)

**Date:** 2026-01-05  
**Status:** ✅ RESOLVED  
**Branch:** `feature/localstack-crossplane`  
**Category:** Branch Management

### Scenario

Feature branch had a merge commit from `main`, creating non-linear history. When attempting to push and create a PR, the history looked messy with unnecessary merge commits instead of a clean linear progression.

### Problem Statement

- Expected: Clean linear commits on top of main
- Actual: Merge commit created history with branching
- Impact: PR merge to main would preserve merge commit unnecessarily
- Root: Used `git merge origin/main` instead of `git rebase`

### Solution

**Step 1:** Create clean temporary branch from `origin/main`
```bash
git checkout -b temp/feature-clean origin/main
```

**Step 2:** Squash all feature changes into one commit
```bash
git merge --squash feature/localstack-crossplane
```

**Step 3:** Commit squashed changes
```bash
git commit -m "feat(crossplane): add EC2 instance support and update documentation (squashed)"
```

**Step 4:** Delete old remote branch
```bash
git push origin --delete feature/localstack-crossplane
```

**Step 5:** Push clean branch to origin
```bash
git push origin HEAD:feature/localstack-crossplane -u
```

**Step 6:** Replace local branch
```bash
git branch -D feature/localstack-crossplane
git branch -m feature/localstack-crossplane
```

### Result

- ✅ Linear history: Single commit on top of main
- ✅ No merge commits
- ✅ Clean repository ready for PR and merge

### Key Lessons

1. Use `git merge --squash` for combining all changes into one commit
2. Use `git rebase` for replaying commits on top of main (linear history)
3. Avoid `git merge` when you want linear history
4. Safe force push: Always use `--force-with-lease` instead of `--force`

### Related Commands

```bash
# View commits on your branch but not in main
git log --oneline origin/main..HEAD

# Safe force push after history rewrite
git push origin branch --force-with-lease
```

---

## Usecase #2: Creating Pull Requests

**Date:** 2026-01-05  
**Status:** ✅ DOCUMENTED  
**Category:** GitHub Workflow

### Scenario

After completing feature work with clean commits, need to create a Pull Request to propose changes for review and eventual merge into main. This usecase covers both Web UI and CLI approaches.

### Problem Statement

- Need: Consistent way to create PRs
- Options: GitHub Web UI or GitHub CLI
- Goal: Fast, documented PR creation process

### Solution

#### Method 1: GitHub Web UI (Most Visual)

**Step 1:** Navigate to Pull Requests
- Go to: https://github.com/OpsAlchemy/kubequest
- Click **"Pull Requests"** tab
- Click **"New Pull Request"**

**Step 2:** Select Branches
- **Base:** `main` (destination branch)
- **Compare:** Your feature branch (e.g., `feature/git-management-and-workflows`)

**Step 3:** Review Diff
- Check all changes are correct
- Ensure only intended files are modified

**Step 4:** Fill PR Details
- **Title:** Follow convention (feat:, fix:, docs:, chore:)
- **Description:** Explain what changed and why
- **Reviewers:** Add team members
- **Labels:** Add if needed (bug, feature, documentation)

**Step 5:** Create PR
- Click **"Create Pull Request"**

#### Method 2: GitHub CLI (Faster for Terminal Users)

**Setup (first time):**
```bash
# Install gh
sudo apt install gh

# Authenticate
gh auth login
```

**Create PR:**
```bash
# Simple PR
gh pr create --title "feat: add feature" --body "Description"

# With options
gh pr create \
  --title "feat: add git management docs and refactor deploy workflow" \
  --body "Adds incident tracking, command reference, and dynamic reusable workflow" \
  --base main

# Create as draft (not ready for review yet)
gh pr create --title "WIP: feature" --body "Draft for feedback" --draft

# Open in browser after creation
gh pr create --title "My PR" --body "Details" --web
```

### PR Template Example

**Title Format:**
```
feat: add git management docs and refactor deploy workflow
```

**Description Template:**
```markdown
## Changes
- Added Git usecases tracking system
- Added command reference guide
- Refactored deploy workflow with reusable actions

## Why
- Team needs centralized Git problem-solving documentation
- Deploy workflow was duplicating code
- Easier to add new docs in future

## Related
- Fixes: Non-linear branch history issue
- Closes: #XX (if applicable)
```

### Checklist Before Submitting

- ✅ Branch has clean, linear history
- ✅ All commits are pushed to origin
- ✅ Branch is up-to-date with main (no conflicts)
- ✅ Code follows project conventions
- ✅ Documentation updated if needed
- ✅ Related scenarios logged in this file
- ✅ PR title follows convention (feat:, fix:, docs:)
- ✅ Description is clear and concise
- ✅ All related issues mentioned

### After PR Creation

**Monitor PR Status:**
```bash
# View your PR
gh pr view

# View in browser
gh pr view --web

# List all open PRs
gh pr list

# Check comments
gh pr view --comments
```

**Responding to Reviews:**
1. Make changes in local branch
2. Commit: `git add . && git commit -m "address review feedback"`
3. Push: `git push origin feature-branch`
4. PR auto-updates with new commits
5. Reply to review comments on GitHub
6. Request re-review when ready

**Merge PR:**

Via CLI (recommended for squash + linear history):
```bash
# Squash merge (combines all commits into one)
gh pr merge --squash

# Merge and delete branch automatically
gh pr merge --squash --delete-branch
```

Via Web UI:
1. Click "Merge pull request"
2. Choose "Squash and merge" strategy
3. Click "Confirm merge"
4. Delete branch

### Result

- ✅ PR created and visible on GitHub
- ✅ Team can review and comment
- ✅ Clear documentation of changes
- ✅ Ready for merge after approval

### Key Lessons

1. Use descriptive PR titles following conventions
2. Write clear, concise descriptions
3. Squash merge preserves linear history
4. Always use `--delete-branch` to clean up after merge
5. GitHub CLI is faster for repetitive PR creation

### Related Resources

- [GitHub PR Documentation](https://docs.github.com/en/pull-requests)
- [GitHub CLI Manual](https://cli.github.com/manual/)

---

## How to Log a New Usecase

When you encounter a new Git scenario:

1. Add a new section: `## Usecase #N: [Title]`
2. Fill in: Date, Status, Category
3. Include these subsections:
   - **Scenario:** What happened
   - **Problem Statement:** What was wrong/unexpected
   - **Solution:** Step-by-step fix with code blocks
   - **Result:** What changed/improved
   - **Key Lessons:** Takeaways for future
   - **Related Commands/Resources:** Links to other docs

4. Commit and create a PR to promote to main

---

## Categories

- **Branch Management:** Creating, switching, deleting branches
- **History Management:** Rebase, squash, merge strategies
- **GitHub Workflow:** PRs, reviews, merges
- **Conflict Resolution:** Handling merge conflicts
- **Remote Sync:** Fetch, pull, push issues
- **Undo/Recovery:** Reverting commits, recovering deleted code
