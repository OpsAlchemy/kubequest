#!/usr/bin/env bash

if [[ -z "$VIRTUAL_ENV" ]]; then
  source .venv/bin/activate
fi

if [[ "$1" == "-compose" ]]; then
  mkdocs serve --livereload -f mkdocs.compose.yml -a 127.0.0.1:9001
else
  mkdocs serve --livereload -a 127.0.0.1:8000
fi
