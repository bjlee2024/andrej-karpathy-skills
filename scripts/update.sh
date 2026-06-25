#!/usr/bin/env bash
# Refresh the karpathy-guidelines block in the global CLAUDE.md to the current
# version. Run this after pulling a new version of the plugin repo.
# Honors CLAUDE_CONFIG_DIR (falls back to ~/.claude).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/_block.sh"

result="$(upsert_block)"
file="$(claude_md_path)"
case "$result" in
  updated) echo "✓ Karpathy Guidelines 블록을 최신 내용으로 갱신했습니다: $file" ;;
  added)   echo "✓ 블록이 없어 새로 추가했습니다: $file" ;;
esac
