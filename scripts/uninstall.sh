#!/usr/bin/env bash
# Remove the karpathy-guidelines block from the global CLAUDE.md, leaving the
# rest of the file untouched. Honors CLAUDE_CONFIG_DIR (falls back to ~/.claude).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/_block.sh"

result="$(remove_block)"
file="$(claude_md_path)"
case "$result" in
  removed) echo "✓ Karpathy Guidelines 블록을 제거했습니다: $file" ;;
  absent)  echo "· 제거할 블록이 없습니다: $file" ;;
esac
