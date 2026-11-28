#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SCRIPT="$REPO_ROOT/sync-agents.sh"

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  grep -Fq -- "$needle" "$file" || fail "$label (missing '$needle' in $file)"
}

assert_not_contains() {
  local file="$1" needle="$2" label="$3"
  if grep -Fq -- "$needle" "$file"; then
    fail "$label (unexpected '$needle' in $file)"
  fi
}

assert_file_exists() {
  local file="$1" label="$2"
  [[ -f "$file" ]] || fail "$label (file missing: $file)"
}

assert_file_absent() {
  local file="$1" label="$2"
  [[ ! -e "$file" ]] || fail "$label (unexpected file exists: $file)"
}

assert_count() {
  local file="$1" needle="$2" expected="$3" label="$4"
  local actual
  actual="$(grep -Fc -- "$needle" "$file" || true)"
  [[ "$actual" == "$expected" ]] || fail "$label (expected $expected occurrences of '$needle', got $actual)"
}

[[ -x "$SCRIPT" ]] || fail "sync-agents.sh must exist and be executable"

# --- Case 1: Existing gentle-ai blocks preserved across Claude, OpenCode, Codex, Gemini CLI, Antigravity, Pi ---
FAKE_HOME="$TMP_ROOT/case1"
SOURCE="$TMP_ROOT/source1.md"
cat >"$SOURCE" <<'EOF'
# Global agent instructions

- Rule alpha
- Rule beta with & and \ and / chars
EOF

mkdir -p "$FAKE_HOME/.claude" "$FAKE_HOME/.config/opencode" "$FAKE_HOME/.codex" \
  "$FAKE_HOME/.gemini/config/rules" "$FAKE_HOME/.pi/agent"

cat >"$FAKE_HOME/.claude/CLAUDE.md" <<'EOF'
<!-- gentle-ai:persona -->
Gentleman persona content
<!-- /gentle-ai:persona -->
EOF
chmod 600 "$FAKE_HOME/.claude/CLAUDE.md"

cat >"$FAKE_HOME/.config/opencode/AGENTS.md" <<'EOF'
<!-- gentle-ai:persona -->
OpenCode persona
<!-- /gentle-ai:persona -->
EOF

cat >"$FAKE_HOME/.codex/AGENTS.md" <<'EOF'
<!-- gentle-ai:persona -->
Codex persona
<!-- /gentle-ai:persona -->
EOF

cat >"$FAKE_HOME/.gemini/GEMINI.md" <<'EOF'
<!-- gentle-ai:gemini-cli-imports -->
@./gentle-ai/01-persona.md
<!-- /gentle-ai:gemini-cli-imports -->
EOF

cat >"$FAKE_HOME/.gemini/config/rules/gentle-ai-01-persona.md" <<'EOF'
---
trigger: always_on
---
Managed by gentle-ai
EOF

HOME="$FAKE_HOME" CODEX_HOME="" SYNC_AGENTS_SOURCE="$SOURCE" "$SCRIPT" >/dev/null

# Verify gentle-ai blocks untouched and dotfiles block added everywhere
assert_contains "$FAKE_HOME/.claude/CLAUDE.md" "Gentleman persona content" "claude keeps gentle-ai"
assert_contains "$FAKE_HOME/.claude/CLAUDE.md" "<!-- dotfiles:global -->" "claude has open marker"
assert_contains "$FAKE_HOME/.claude/CLAUDE.md" "Rule beta with & and \\ and / chars" "claude preserves special chars"
assert_contains "$FAKE_HOME/.claude/CLAUDE.md" "<!-- /dotfiles:global -->" "claude has close marker"

# Verify file mode preserved (0600)
MODE="$(stat -f '%Lp' "$FAKE_HOME/.claude/CLAUDE.md" 2>/dev/null || stat -c '%a' "$FAKE_HOME/.claude/CLAUDE.md")"
[[ "$MODE" == "600" ]] || fail "claude file permissions should stay 600, got $MODE"

assert_contains "$FAKE_HOME/.config/opencode/AGENTS.md" "OpenCode persona" "opencode keeps gentle-ai"
assert_contains "$FAKE_HOME/.config/opencode/AGENTS.md" "Rule alpha" "opencode gets rules"

assert_contains "$FAKE_HOME/.codex/AGENTS.md" "Codex persona" "codex keeps gentle-ai"
assert_contains "$FAKE_HOME/.codex/AGENTS.md" "Rule alpha" "codex gets rules"

# Antigravity gets standalone rule outside gentle-ai-NN- namespace; gentle-ai rule untouched
assert_file_exists "$FAKE_HOME/.gemini/config/rules/dotfiles-global.md" "antigravity rule created"
assert_contains "$FAKE_HOME/.gemini/config/rules/dotfiles-global.md" "trigger: always_on" "antigravity rule is always_on"
assert_contains "$FAKE_HOME/.gemini/config/rules/dotfiles-global.md" "Rule alpha" "antigravity gets rules"
assert_contains "$FAKE_HOME/.gemini/config/rules/gentle-ai-01-persona.md" "Managed by gentle-ai" "antigravity gentle-ai rule untouched"

# Gemini CLI imports via @./dotfiles-global.md to avoid duplicating full text into Antigravity
assert_file_exists "$FAKE_HOME/.gemini/dotfiles-global.md" "gemini helper file created"
assert_contains "$FAKE_HOME/.gemini/dotfiles-global.md" "Rule alpha" "gemini helper gets rules"
assert_contains "$FAKE_HOME/.gemini/GEMINI.md" "@./gentle-ai/01-persona.md" "gemini keeps gentle-ai imports"
assert_contains "$FAKE_HOME/.gemini/GEMINI.md" "@./dotfiles-global.md" "gemini imports dotfiles-global"
assert_not_contains "$FAKE_HOME/.gemini/GEMINI.md" "Rule alpha" "GEMINI.md must not inline full rules"

# Pi regular file gets rules
assert_file_exists "$FAKE_HOME/.pi/agent/AGENTS.md" "pi AGENTS.md created"
assert_contains "$FAKE_HOME/.pi/agent/AGENTS.md" "Rule alpha" "pi gets rules"

# --- Case 2: Idempotency and update propagation ---
CLAUDE_BEFORE="$(cat "$FAKE_HOME/.claude/CLAUDE.md")"
HOME="$FAKE_HOME" CODEX_HOME="" SYNC_AGENTS_SOURCE="$SOURCE" "$SCRIPT" >/dev/null
CLAUDE_AFTER="$(cat "$FAKE_HOME/.claude/CLAUDE.md")"
[[ "$CLAUDE_BEFORE" == "$CLAUDE_AFTER" ]] || fail "second run must be idempotent"
assert_count "$FAKE_HOME/.claude/CLAUDE.md" "<!-- dotfiles:global -->" 1 "no duplicate markers"

cat >"$SOURCE" <<'EOF'
# Global agent instructions

- Rule gamma updated
EOF

HOME="$FAKE_HOME" CODEX_HOME="" SYNC_AGENTS_SOURCE="$SOURCE" "$SCRIPT" >/dev/null

for f in \
  "$FAKE_HOME/.claude/CLAUDE.md" \
  "$FAKE_HOME/.config/opencode/AGENTS.md" \
  "$FAKE_HOME/.codex/AGENTS.md" \
  "$FAKE_HOME/.gemini/config/rules/dotfiles-global.md" \
  "$FAKE_HOME/.gemini/dotfiles-global.md" \
  "$FAKE_HOME/.pi/agent/AGENTS.md"; do
  assert_contains "$f" "Rule gamma updated" "updated rule propagated to $f"
  assert_not_contains "$f" "Rule alpha" "old rule replaced in $f"
done
assert_contains "$FAKE_HOME/.claude/CLAUDE.md" "Gentleman persona content" "gentle-ai still intact after update"

# --- Case 3: Uninstalled agents are skipped without creating directories ---
FAKE_HOME3="$TMP_ROOT/case3"
mkdir -p "$FAKE_HOME3/.claude"
HOME="$FAKE_HOME3" CODEX_HOME="" SYNC_AGENTS_SOURCE="$SOURCE" "$SCRIPT" >/dev/null
assert_file_exists "$FAKE_HOME3/.claude/CLAUDE.md" "installed claude synced"
assert_file_absent "$FAKE_HOME3/.config/opencode" "uninstalled opencode skipped"
assert_file_absent "$FAKE_HOME3/.codex" "uninstalled codex skipped"
assert_file_absent "$FAKE_HOME3/.gemini" "uninstalled gemini skipped"
assert_file_absent "$FAKE_HOME3/.pi" "uninstalled pi skipped"

# --- Case 4: Symlink refusal on gentle-ai-managed file ---
FAKE_HOME4="$TMP_ROOT/case4"
mkdir -p "$FAKE_HOME4/.claude"
printf 'original\n' >"$TMP_ROOT/symtarget.md"
ln -s "$TMP_ROOT/symtarget.md" "$FAKE_HOME4/.claude/CLAUDE.md"
if HOME="$FAKE_HOME4" CODEX_HOME="" SYNC_AGENTS_SOURCE="$SOURCE" "$SCRIPT" >/dev/null 2>&1; then
  fail "must refuse symlinked CLAUDE.md"
fi
[[ -L "$FAKE_HOME4/.claude/CLAUDE.md" ]] || fail "symlink must not be replaced"
[[ "$(cat "$TMP_ROOT/symtarget.md")" == "original" ]] || fail "symlink target must remain untouched"

# --- Case 5: Pi symlink already pointing to SOURCE is a clean no-op ---
FAKE_HOME5="$TMP_ROOT/case5"
mkdir -p "$FAKE_HOME5/.pi/agent"
ln -s "$SOURCE" "$FAKE_HOME5/.pi/agent/AGENTS.md"
HOME="$FAKE_HOME5" CODEX_HOME="" SYNC_AGENTS_SOURCE="$SOURCE" "$SCRIPT" >/dev/null
[[ -L "$FAKE_HOME5/.pi/agent/AGENTS.md" ]] || fail "pi symlink to SOURCE must remain a symlink"

# --- Case 6: Pi stale symlink warns and is NOT clobbered ---
FAKE_HOME6="$TMP_ROOT/case6"
mkdir -p "$FAKE_HOME6/.pi/agent"
ln -s "$TMP_ROOT/does-not-exist.md" "$FAKE_HOME6/.pi/agent/AGENTS.md"
OUT6="$(HOME="$FAKE_HOME6" CODEX_HOME="" SYNC_AGENTS_SOURCE="$SOURCE" "$SCRIPT" 2>&1)"
[[ -L "$FAKE_HOME6/.pi/agent/AGENTS.md" ]] || fail "stale pi symlink must not be clobbered"
printf '%s\n' "$OUT6" | grep -Fq "rebuild.sh" || fail "stale pi symlink should advise running rebuild.sh"

# --- Case 7: Orphan marker refusal ---
FAKE_HOME7="$TMP_ROOT/case7"
mkdir -p "$FAKE_HOME7/.claude"
cat >"$FAKE_HOME7/.claude/CLAUDE.md" <<'EOF'
<!-- dotfiles:global -->
unclosed block
EOF
if HOME="$FAKE_HOME7" CODEX_HOME="" SYNC_AGENTS_SOURCE="$SOURCE" "$SCRIPT" >/dev/null 2>&1; then
  fail "must refuse unclosed marker block"
fi
assert_contains "$FAKE_HOME7/.claude/CLAUDE.md" "unclosed block" "corrupt file left untouched"

# --- Case 8: Custom CODEX_HOME respected ---
FAKE_HOME8="$TMP_ROOT/case8"
CUSTOM_CODEX="$TMP_ROOT/custom-codex"
mkdir -p "$FAKE_HOME8" "$CUSTOM_CODEX"
HOME="$FAKE_HOME8" CODEX_HOME="$CUSTOM_CODEX" SYNC_AGENTS_SOURCE="$SOURCE" "$SCRIPT" >/dev/null
assert_file_exists "$CUSTOM_CODEX/AGENTS.md" "CODEX_HOME respected"
assert_contains "$CUSTOM_CODEX/AGENTS.md" "Rule gamma updated" "CODEX_HOME got rules"

# --- Case 9: CRLF target file replaces existing block without duplicating ---
FAKE_HOME9="$TMP_ROOT/case9"
mkdir -p "$FAKE_HOME9/.claude"
printf '<!-- gentle-ai:persona -->\r\nPersona\r\n<!-- /gentle-ai:persona -->\r\n\r\n<!-- dotfiles:global -->\r\nold crlf rule\r\n<!-- /dotfiles:global -->\r\n' >"$FAKE_HOME9/.claude/CLAUDE.md"
HOME="$FAKE_HOME9" CODEX_HOME="" SYNC_AGENTS_SOURCE="$SOURCE" "$SCRIPT" >/dev/null
assert_count "$FAKE_HOME9/.claude/CLAUDE.md" "<!-- dotfiles:global -->" 1 "CRLF file must not duplicate block"
assert_not_contains "$FAKE_HOME9/.claude/CLAUDE.md" "old crlf rule" "CRLF stale rule must be replaced"
assert_contains "$FAKE_HOME9/.claude/CLAUDE.md" "Rule gamma updated" "CRLF file receives updated rule"

# --- Case 10: gentle-ai blocks before/after dotfiles block + missing trailing newlines ---
FAKE_HOME10="$TMP_ROOT/case10"
SOURCE10="$TMP_ROOT/source10.md"
mkdir -p "$FAKE_HOME10/.claude"
printf '# Global\n- no newline at EOF' >"$SOURCE10"
printf '<!-- gentle-ai:persona -->\nBefore\n<!-- /gentle-ai:persona -->\n\n<!-- dotfiles:global -->\nstale\n<!-- /dotfiles:global -->\n\n<!-- gentle-ai:engram -->\nAfter\n<!-- /gentle-ai:engram -->' >"$FAKE_HOME10/.claude/CLAUDE.md"
HOME="$FAKE_HOME10" CODEX_HOME="" SYNC_AGENTS_SOURCE="$SOURCE10" "$SCRIPT" >/dev/null
EXPECTED10=$'<!-- gentle-ai:persona -->\nBefore\n<!-- /gentle-ai:persona -->\n\n<!-- dotfiles:global -->\n# Global\n- no newline at EOF\n<!-- /dotfiles:global -->\n\n<!-- gentle-ai:engram -->\nAfter\n<!-- /gentle-ai:engram -->'
[[ "$(cat "$FAKE_HOME10/.claude/CLAUDE.md")" == "$EXPECTED10" ]] || fail "block must be replaced in place between gentle-ai blocks"
HOME="$FAKE_HOME10" CODEX_HOME="" SYNC_AGENTS_SOURCE="$SOURCE10" "$SCRIPT" >/dev/null
[[ "$(cat "$FAKE_HOME10/.claude/CLAUDE.md")" == "$EXPECTED10" ]] || fail "second run with missing trailing newline must be idempotent"

# --- Case 11: Antigravity config dir without rules/ subdir yet (and no Gemini CLI) ---
FAKE_HOME11="$TMP_ROOT/case11"
mkdir -p "$FAKE_HOME11/.gemini/config"
HOME="$FAKE_HOME11" CODEX_HOME="" SYNC_AGENTS_SOURCE="$SOURCE" "$SCRIPT" >/dev/null
assert_file_exists "$FAKE_HOME11/.gemini/config/rules/dotfiles-global.md" "antigravity creates rules dir"
assert_file_absent "$FAKE_HOME11/.gemini/GEMINI.md" "antigravity-only setup must not create GEMINI.md"
assert_file_absent "$FAKE_HOME11/.gemini/dotfiles-global.md" "antigravity-only setup must not create gemini helper"

# --- Case 12: 2-hop Home Manager Pi symlink + paths with spaces ---
FAKE_HOME12="$TMP_ROOT/case 12/home dir"
DOT_REAL="$TMP_ROOT/case 12/repo dir"
NIX_STORE="$TMP_ROOT/case 12/nix store"
mkdir -p "$FAKE_HOME12/.pi/agent" "$DOT_REAL/home" "$NIX_STORE"
printf '# Global\n- space rule\n' >"$DOT_REAL/home/AGENTS.md"
ln -s "$DOT_REAL" "$FAKE_HOME12/.dotfiles"
ln -s "$FAKE_HOME12/.dotfiles/home/AGENTS.md" "$NIX_STORE/AGENTS.md"
ln -s "$NIX_STORE/AGENTS.md" "$FAKE_HOME12/.pi/agent/AGENTS.md"
OUT12="$(HOME="$FAKE_HOME12" CODEX_HOME="" SYNC_AGENTS_SOURCE="$FAKE_HOME12/.dotfiles/home/AGENTS.md" "$SCRIPT" 2>&1)"
printf '%s\n' "$OUT12" | grep -Fq "ok      pi" || fail "2-hop Home Manager symlink with spaces should report ok"

# --- Case 13: Orphan close marker preserves file byte-identically and isolates sibling agents ---
FAKE_HOME13="$TMP_ROOT/case13"
mkdir -p "$FAKE_HOME13/.claude" "$FAKE_HOME13/.config/opencode"
printf 'keep\n<!-- /dotfiles:global -->\n' >"$FAKE_HOME13/.claude/CLAUDE.md"
printf 'oc\n' >"$FAKE_HOME13/.config/opencode/AGENTS.md"
BEFORE13="$(cat "$FAKE_HOME13/.claude/CLAUDE.md")"
if HOME="$FAKE_HOME13" CODEX_HOME="" SYNC_AGENTS_SOURCE="$SOURCE" "$SCRIPT" >/dev/null 2>&1; then
  fail "must refuse orphan close marker"
fi
[[ "$(cat "$FAKE_HOME13/.claude/CLAUDE.md")" == "$BEFORE13" ]] || fail "orphan close marker file must remain unchanged"
assert_contains "$FAKE_HOME13/.config/opencode/AGENTS.md" "Rule gamma updated" "sibling agent must still sync on claude failure"

# --- Case 14: Empty source fails closed; broken GEMINI.md symlink refuses without creating helper ---
FAKE_HOME14="$TMP_ROOT/case14"
EMPTY_SRC="$TMP_ROOT/empty.md"
: >"$EMPTY_SRC"
mkdir -p "$FAKE_HOME14/.claude" "$FAKE_HOME14/.gemini"
printf 'keep\n' >"$FAKE_HOME14/.claude/CLAUDE.md"
if HOME="$FAKE_HOME14" CODEX_HOME="" SYNC_AGENTS_SOURCE="$EMPTY_SRC" "$SCRIPT" >/dev/null 2>&1; then
  fail "must refuse empty source file"
fi
[[ "$(cat "$FAKE_HOME14/.claude/CLAUDE.md")" == "keep" ]] || fail "empty source must leave targets untouched"

ln -s "$TMP_ROOT/missing-gemini.md" "$FAKE_HOME14/.gemini/GEMINI.md"
if HOME="$FAKE_HOME14" CODEX_HOME="" SYNC_AGENTS_SOURCE="$SOURCE" "$SCRIPT" >/dev/null 2>&1; then
  fail "must refuse broken GEMINI.md symlink"
fi
assert_file_absent "$FAKE_HOME14/.gemini/dotfiles-global.md" "rejected GEMINI.md must not leave unreferenced helper"

printf 'PASS: all sync-agents.sh tests passed\n'
