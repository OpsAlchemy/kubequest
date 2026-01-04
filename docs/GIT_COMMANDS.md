# Git Command Reference

Quick lookup for common Git commands. For real-world solutions, see `GIT_INCIDENTS.md`.

---

## Checking Status & History

```bash
# Current branch and files
git status

# Commits on your branch but not in main
git log origin/main..HEAD --oneline

# Commits on main but not on your branch
git log HEAD..origin/main --oneline

# Detailed history with branches
git log --graph --oneline --all

# What changed in a specific commit
git show <commit-hash>
```

---

## Branches

```bash
# List all branches
git branch -a

# Create branch from main
git checkout -b feature/name origin/main

# Switch branch
git checkout feature/name
git switch feature/name  # newer syntax

# Delete local branch
git branch -d feature/name

# Delete remote branch
git push origin --delete feature/name

# Rename branch (when on it)
git branch -m new-name
```

---

## Undo & Recover

```bash
# Undo last commit, keep changes staged
git reset --soft HEAD~1

# Undo last commit, keep changes unstaged
git reset --mixed HEAD~1

# Undo last commit, discard changes
git reset --hard HEAD~1

# Undo pushed commit (creates new revert commit)
git revert <commit-hash>

# Find deleted commit/branch
git reflog
git checkout -b recovered <commit-hash>
```

---

## Linear History

```bash
# Rebase onto main (replay commits on top)
git rebase origin/main

# Squash-merge (all changes as one commit)
git merge --squash feature/branch
git commit -m "Message"

# Safe force push after history rewrite
git push origin branch --force-with-lease
```

---

## Merge & Conflicts

```bash
# Abort merge
git merge --abort

# Abort rebase
git rebase --abort

# Keep our version of file
git checkout --ours path/to/file

# Keep their version of file
git checkout --theirs path/to/file

# Mark file as resolved
git add path/to/file
```

---

## Sync with Remote

```bash
# Update remote tracking branches
git fetch origin

# Pull with rebase (cleaner than merge)
git pull --rebase origin main

# Push branch
git push -u origin feature/name
```

---

## Quick Help

```bash
git help <command>  # Detailed help for any command
```
