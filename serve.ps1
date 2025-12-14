param(
  [switch]$compose
)

if (-not $compose -and $args -contains "--compose") {
  $compose = $true
}

if (-not $env:VIRTUAL_ENV) {
  . .\.venv\Scripts\Activate.ps1
}

if ($compose) {
  mkdocs serve --livereload -f mkdocs.compose.yml -a 127.0.0.1:9001
} else {
  mkdocs serve --livereload -a 127.0.0.1:8000
}
