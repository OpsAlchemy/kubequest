#!/usr/bin/env bash
set -euo pipefail

SOL="sol.yaml"

i=1
out="sol${i}.yaml"
echo "" > "$out"

while IFS= read -r line || [ -n "$line" ]; do
  clean="${line%$'\r'}"

  if [ "$clean" = "---" ]; then
    i=$((i+1))
    out="sol${i}.yaml"
    echo "" > "$out"
  else
    echo "$clean" >> "$out"
  fi
done < "$SOL"



# SOL="sol.yaml"

# echo "=== RESTORE START ==="

# if [ ! -f "$SOL" ]; then
#   echo "ERROR: $SOL does not exist"
#   exit 1
# fi

# echo "Using source file: $SOL"
# echo "--------------------------------"

# i=1
# out="sol${i}.yaml.tmp"

# echo "Creating first output file: $out"
# echo "" > "$out"

# line_no=0

# while IFS= read -r line || [ -n "$line" ]; do
#   line_no=$((line_no+1))

#   # Strip CR if present (WSL / Windows)
#   clean="${line%$'\r'}"

#   echo "[line $line_no] RAW:   '$line'"
#   echo "[line $line_no] CLEAN: '$clean'"

#   if [ "$clean" = "---" ]; then
#     echo "[line $line_no] FOUND SEPARATOR ---"
#     i=$((i+1))
#     out="sol${i}.yaml.tmp"
#     echo "[line $line_no] Creating new file: $out"
#     echo "" > "$out"
#   else
#     echo "[line $line_no] Writing to $out"
#     echo "$clean" >> "$out"
#   fi

# done < "$SOL"

# echo "--------------------------------"
# echo "Restore parsing complete"
# echo "Generated temp files:"
# ls -l sol*.yaml.tmp || echo "No temp files created"

# echo "=== RESTORE END ==="


