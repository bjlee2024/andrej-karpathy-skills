# Shared library for managing the karpathy-skills block in the global CLAUDE.md.
# Sourced by install.sh / update.sh / uninstall.sh — not meant to be run directly.

BLOCK_BEGIN='<!-- BEGIN karpathy-skills (managed — do not edit by hand) -->'
BLOCK_END='<!-- END karpathy-skills -->'

# Path to the global CLAUDE.md (honors CLAUDE_CONFIG_DIR, falls back to ~/.claude).
claude_md_path() {
  printf '%s/CLAUDE.md' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
}

# The managed block — single source of truth for what gets written.
block_content() {
  cat <<EOF
$BLOCK_BEGIN
## Karpathy Guidelines (always-on)

Before writing, reviewing, or refactoring code, always apply the
\`karpathy-guidelines\` skill to avoid overcomplication, make surgical
changes, surface assumptions, and define verifiable success criteria.
$BLOCK_END
EOF
}

# Add or refresh the block. Finds the block by markers, never by content, so it
# is idempotent and never touches the user's own CLAUDE.md text.
# Prints "added" or "updated". Writes atomically (temp file + mv).
upsert_block() {
  local file new_block tmp
  file="$(claude_md_path)"
  new_block="$(block_content)"
  mkdir -p "$(dirname "$file")"

  if [ ! -f "$file" ]; then
    printf '%s\n' "$new_block" > "$file"
    echo "added"
    return
  fi

  tmp="$(mktemp "${file}.XXXXXX")"
  if grep -qF "$BLOCK_BEGIN" "$file"; then
    # Replace the existing block in place.
    REPL="$new_block" awk -v b="$BLOCK_BEGIN" -v e="$BLOCK_END" '
      $0 == b { print ENVIRON["REPL"]; skip=1; next }
      skip && $0 == e { skip=0; next }
      skip { next }
      { print }
    ' "$file" > "$tmp"
    mv "$tmp" "$file"
    echo "updated"
  else
    # Append, separated from existing content by one blank line.
    cp "$file" "$tmp"
    [ -s "$tmp" ] && printf '\n' >> "$tmp"
    printf '%s\n' "$new_block" >> "$tmp"
    mv "$tmp" "$file"
    echo "added"
  fi
}

# Remove the block and tidy trailing blank lines. Leaves the rest of the file
# untouched. Prints "removed" or "absent".
remove_block() {
  local file tmp
  file="$(claude_md_path)"
  if [ ! -f "$file" ] || ! grep -qF "$BLOCK_BEGIN" "$file"; then
    echo "absent"
    return
  fi

  tmp="$(mktemp "${file}.XXXXXX")"
  awk -v b="$BLOCK_BEGIN" -v e="$BLOCK_END" '
    $0 == b { skip=1; next }
    skip && $0 == e { skip=0; next }
    skip { next }
    { lines[NR] = $0 }
    END {
      last = NR
      while (last > 0 && lines[last] == "") last--
      for (i = 1; i <= last; i++) if (i in lines) print lines[i]
    }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
  echo "removed"
}
