---
name: shortcuts-pdf
description: Regenerates the personal keyboard-shortcuts PDF (Vim basics, Neovim custom binds + plugin defaults, herdr, WezTerm) by reading the live dotfiles config, and overwrites ~/Documents/new-agentic-workflow-shortcuts.pdf. Use when the user asks to update/regenerate the shortcuts PDF, or after adding/changing a keybind, or adding/removing a Neovim plugin or herdr binding.
---

# Shortcuts PDF

Regenerates `~/Documents/new-agentic-workflow-shortcuts.pdf`, a personal cheat sheet covering Vim
fundamentals, Neovim (custom binds + relevant plugin defaults), herdr, and WezTerm. All dynamic
content must be read fresh from the live config each run, not hardcoded here — the whole point of
this skill is that it never goes stale.

`reference.html` in this skill's folder is a known-good, already-rendered example. Reuse its exact
CSS and structure (2-column layout, `<kbd>` styling, `.tag`/`.note`/`.empty-note` conventions) every
time; only the table rows change based on what the config actually contains.

## 1. Read the dynamic sources (paths relative to `~/.dotfiles`, the stable repo alias)

- `home/.config/nvim/lua/vim_config.lua` — grep `vim.g.mapleader` for the leader key.
- `home/.config/nvim/lua/keys.lua` — every `vim.keymap.set(...)` call, using its `desc` for the label.
- `home/.config/nvim/lua/plugins/*.lua` — glob **all** files in this directory (new plugins add new
  files here). For each plugin table that has an explicit `keys = { ... }`, list those binds under
  that plugin's own section, using each entry's `desc`.
- `home/.config/herdr/config.toml` — every `key = "value"` line under `[keys]` (skip `[ui]`, that's
  not a keybind). Carry over any inline `#` comment as a `.note` (e.g. the copy-mode comment).
- `home/.config/wezterm/wezterm.lua` — check for a `config.keys = { ... }` table. If present, list
  those binds. If absent (as of 2026-08-31, by explicit user decision), keep the WezTerm section as
  a single `.empty-note`: "Sin overrides de teclado en wezterm.lua: usa los atajos por default de la
  aplicación (ver wezterm.org/config/default-keys.html)." Do not enumerate WezTerm's built-in
  defaults — there's nothing in the repo declaring them, so there's nothing to keep in sync.

## 2. Plugin *default* keymaps (when a plugin has no explicit `keys` table, or to document what its
   defaults do beyond the custom entry point)

For plugins whose useful keymaps are the plugin's own defaults rather than something declared in
this repo (currently: oil.nvim, neogit), don't guess from memory — grep the actual installed plugin
source under `~/.local/share/nvim/lazy/<plugin-repo-name>/`:

- **oil.nvim**: `lua/oil/config.lua`, the `keymaps = { ... }` table (around `default_config.keymaps`).
- **neogit**: `lua/neogit/config.lua`, the `mappings = { ... }` table — specifically the nested
  `status = { ... }` block (the status-buffer binds: stage/unstage/discard/toggle-diff/etc.) and the
  `popup = { ... }` block (single-letter menu openers: commit/push/pull/log/diff).

If a new plugin shows up in `lua/plugins/*.lua` without an explicit `keys` table and it's a
well-known plugin with its own default keymaps worth documenting, follow the same pattern: find it
under `~/.local/share/nvim/lazy/<name>/`, locate its default keymap table in its Lua source, and add
a new section for it (mark it with the `Default de Neovim` / `Defaults del plugin` `.tag` used in
`reference.html`, exactly like oil.nvim and neogit).

## 3. Vim fundamentals section

Static reference material — modes, movement, select/delete/yank/paste, undo/redo, jumplist
(`Ctrl-o`/`Ctrl-i`). Reuse the "Vim — lo básico" section from `reference.html` as-is unless the user
asks to add/remove something from it.

## 4. Build the HTML and convert to PDF

1. Write the full HTML to a scratch file (use the scratchpad directory), following `reference.html`'s
   structure and CSS exactly. All labels/notes are in Spanish.
2. Convert with headless Chrome (no other PDF tool is installed on this machine):

   ```bash
   "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
     --headless --disable-gpu --no-pdf-header-footer \
     --print-to-pdf="$HOME/Documents/new-agentic-workflow-shortcuts.pdf" \
     "file://<path-to-scratch-html>"
   ```

   Stderr noise like `Trying to load the allocator multiple times` or `task_policy_set ... invalid
   argument` is harmless Chrome logging, not a failure — check the actual exit and the "N bytes
   written to file" message instead.
3. Verify with `file ~/Documents/new-agentic-workflow-shortcuts.pdf` (should report a PDF document)
   before telling the user it's done.
4. After generating, update this skill's `reference.html` copy to match what was just produced, so
   the next run's template stays in sync with any structural changes made this run.

## Maintaining this file

Keep this file for knowledge useful to every future run of this skill. Prefer rewriting entries over
appending new ones as the config evolves. If a section's extraction recipe changes (a file moves, a
plugin is replaced), update the recipe here rather than leaving stale instructions next to new ones.
