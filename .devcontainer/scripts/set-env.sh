#!/bin/bash

AWS_KEY="DO008MCEP2QL3BKABFM9"
AWS_SECRET="yDQowk5n+TkjubffF2r/iCaunLm+HDrCVwp8BfZo0Gc"
GLOBAL_BASHRC="/etc/bash.bashrc"

LINE1="export AWS_ACCESS_KEY_ID=\"$AWS_KEY\""
LINE2="export AWS_SECRET_ACCESS_KEY=\"$AWS_SECRET\""

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script as root (use sudo)."
  exit 1
fi

grep -qxF "$LINE1" "$GLOBAL_BASHRC" || echo "$LINE1" >> "$GLOBAL_BASHRC"
grep -qxF "$LINE2" "$GLOBAL_BASHRC" || echo "$LINE2" >> "$GLOBAL_BASHRC"

echo "AWS credentials added to $GLOBAL_BASHRC"

source "$GLOBAL_BASHRC"
echo "Reloaded $GLOBAL_BASHRC"
