#!/usr/bin/env bash
# Add the karpathy-guidelines "always-on" directive to the global CLAUDE.md,
# so the skill applies in every Claude Code session — not only when invoked.
# Safe to run repeatedly. Honors CLAUDE_CONFIG_DIR (falls back to ~/.claude).
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$DIR/_block.sh"

result="$(upsert_block)"
file="$(claude_md_path)"
case "$result" in
  added)   echo "✓ Karpathy Guidelines 블록을 추가했습니다: $file" ;;
  updated) echo "✓ 이미 설치되어 있어 블록을 최신 내용으로 갱신했습니다: $file" ;;
esac
echo "  이제 모든 세션에서 karpathy-guidelines 스킬이 항상 적용됩니다."
