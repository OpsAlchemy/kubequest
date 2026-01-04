# Git Incidents & Solutions

Real problems encountered and solved in this repository. Log each incident here as it happens.

---

## Incident #1: Non-Linear Branch History (Unwanted Merge Commit)

**Date:** 2026-01-05  
**Status:** ✅ RESOLVED  
**Branch:** `feature/localstack-crossplane`

### Problem

Feature branch had a merge commit from `main`, creating non-linear history:
- Expected: Clean linear commits on top of main
- Actual: Merge commit made history messy
- Issue: PR merge to main would be complicated

### Root Cause

```bash
git merge origin/main  # Created unwanted merge commit
```

### Solution

1. Create clean temp branch from `origin/main`:
```bash
git checkout -b temp/feature-clean origin/main
```

2. Squash all feature changes into one commit:
```bash
git merge --squash feature/localstack-crossplane
```

3. Commit squashed changes:
```bash
git commit -m "feat(crossplane): add EC2 instance support and update documentation (squashed)"
```

4. Delete old remote branch:
```bash
git push origin --delete feature/localstack-crossplane
```

5. Push clean branch to origin:
```bash
git push origin HEAD:feature/localstack-crossplane -u
```

6. Replace local branch:
```bash
git branch -D feature/localstack-crossplane
git branch -m feature/localstack-crossplane
```

### Result

- ✅ Linear history (single commit on top of main)
- ✅ No merge commits
- ✅ Ready for PR merge

### Key Takeaway

Use `git merge --squash` or `git rebase` for linear history, not `git merge`

---

## How to Log an Incident

When you fix a Git issue:

1. Add a new section with `## Incident #N: [Title]`
2. Include: Date, Status, Branch (if applicable)
3. Document: Problem, Root Cause, Solution (step-by-step), Result, Key Takeaway
4. Keep it concise and action-oriented
5. Create a PR to promote to main
