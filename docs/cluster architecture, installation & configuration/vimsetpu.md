# Minimal Vim Configuration for CKA

**File name:** `vim-minimal-cka-config.md`

```vimrc
" ~/.vimrc - Minimal CKA Configuration
set expandtab
set tabstop=2
set shiftwidth=2
set number
syntax on
set hlsearch
set autoindent
```

**6 essential lines for CKA:**

1. **`set expandtab`** - Spaces instead of tabs (required for YAML)
2. **`set tabstop=2`** - 2 spaces per tab (Kubernetes standard)
3. **`set shiftwidth=2`** - 2 spaces for indentation
4. **`set number`** - Show line numbers (helps with debugging)
5. **`syntax on`** - Syntax highlighting (spot errors faster)
6. **`set hlsearch`** - Highlight search matches
7. **`set autoindent`** - Automatic indentation

**Create it quickly:**
```bash
cat > ~/.vimrc << 'EOF'
set expandtab
set tabstop=2
set shiftwidth=2
set number
syntax on
set hlsearch
set autoindent
EOF
```

That's all you need for the CKA exam - nothing more.