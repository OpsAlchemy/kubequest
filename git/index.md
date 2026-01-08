# Git Learning & Reference

Complete Git guide with real-world scenarios from managing this repository.

## Quick Links

- [Commands](docs/GIT_COMMANDS.md) - Common git commands by category
- [Usecases](docs/GIT_USECASES.md) - Real scenarios with solutions

## Key Techniques

### Linear History
Use `git reset --soft` to linearize messy histories:
```bash
git reset --soft <commit>
git commit -m "message"
git push origin main --force-with-lease
```

See [Usecase #3](docs/GIT_USECASES.md) for complete example.

## Safety First

- Always use `--force-with-lease` instead of `--force`
- Create backups: `git branch backup-before-change`
- Recover anything with `git reflog`
