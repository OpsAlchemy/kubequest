# GitHub Actions Documentation Setup

## Adding New Documentation Sites

To add a new documentation site to the CI/CD pipeline:

### 1. Create your MkDocs project

```bash
mkdir -p backstage/docs
cd backstage

# Create mkdocs.yml
cat > mkdocs.yml << 'EOF'
site_name: Backstage Setup Guide
docs_dir: docs
theme:
  name: material
EOF

# Create requirements.txt if needed
cat > requirements.txt << 'EOF'
mkdocs==1.6.1
mkdocs-material==9.7.0
EOF
```

### 2. Add to `.github/docs-config.json`

```json
{
  "name": "backstage",
  "mkdocs_config": "backstage/mkdocs.yml",
  "output_folder": "backstage",
  "requirements_file": "backstage/requirements.txt"
}
```

### 3. Update workflow trigger (if needed)

Edit `.github/workflows/deploy.yaml` and add the path to the `paths` trigger:

```yaml
on:
  push:
    paths:
      - "cka/**"
      - "backstage/**"  # Add this line
      - ".github/workflows/deploy.yaml"
      - ".github/actions/build-mkdocs/**"
      - ".github/docs-config.json"  # Config changes also trigger
```

### 4. Push and test

```bash
git add .github/docs-config.json .github/workflows/deploy.yaml backstage/
git commit -m "docs: add backstage documentation site"
git push
```

The workflow will automatically:
- ✅ Read your config from `docs-config.json`
- ✅ Build with the correct mkdocs config
- ✅ Deploy to your custom output folder
- ✅ Combine all sites into one `_site/`

## Matrix Fields

| Field | Description | Example |
|-------|-------------|---------|
| `name` | Unique identifier for artifact naming | `"backstage"` |
| `mkdocs_config` | Path to mkdocs.yml | `"backstage/mkdocs.yml"` |
| `output_folder` | Where to output built site | `"backstage"` |
| `requirements_file` | Path to requirements.txt (optional) | `"backstage/requirements.txt"` |

## Troubleshooting

### Build fails with "mkdocs config not found"
- Verify the `mkdocs_config` path is correct relative to repo root
- Ensure the file exists: `git ls-files | grep mkdocs`

### Site doesn't appear in final output
- Check that `output_folder` name matches the intended URL path
- Verify `name` is unique (no duplicates in `docs-config.json`)

### Slow builds
- Add to `.gitignore`: `_site/`, `site/`, `*.egg-info/`
- Cache is automatic (pip cache via actions/cache@v3)

## Current Sites

The pipeline currently builds and deploys:
- **docs** → `cka/mkdocs.yml` → `./_site/docs/`
- **compose** → `cka/mkdocs.compose.yml` → `./_site/compose/`

All sites are deployed to GitHub Pages at: `https://opsalchemy.github.io/kubequest/`
