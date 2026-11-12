-- Atom Just Black on top of isaias-alt/atom-one.nvim.
--
-- Ground truth is the installed VS Code extension, not the 2020 GitHub repo it
-- links to:
--   ~/.vscode/extensions/dereckdamphouse.atom-just-black-1.0.6/themes/AtomJustBlackTheme.json
--
-- atom-one.nvim's `onedark` variant already maps the upstream One Dark Pro
-- TextMate scopes onto Treesitter captures, and its eight syntax colors are the
-- same ones this theme inherits verbatim, so nothing here touches them. Only
-- two kinds of field differ:
--
--   1. every UI-chrome surface, because Just Black repaints them #000000
--   2. the comment gray: this theme predates One Dark Pro's move to #7F848E and
--      still uses Atom's #5C6370
--
-- Every value below cites the VS Code `colors.*` / tokenColors scope it comes
-- from. 8-digit alpha colors are composited over #000000 with the same math VS
-- Code uses, so the rendered pixel matches.

local blend = require("atom-one.util").blend

local M = {}

local BG = "#000000"

---@param c atom-one.Palette
function M.on_colors(c)
  -- Surfaces
  c.bg = BG -- editor.background
  c.bg_dark = BG -- sideBar.background, statusBar.background, tab backgrounds
  c.bg_popup = BG -- editorWidget / editorSuggestWidget / editorHoverWidget.background
  c.bg_statusline = BG -- statusBar.background
  c.bg_highlight = blend("#99BBFF", 0x0A / 0xFF, BG) -- editor.lineHighlightBackground #99BBFF0A
  c.bg_visual = "#3E4451" -- editor.selectionBackground
  -- editor.findMatchBackground is #000000 (invisible over the editor), so the
  -- highlight variant stands in for both search surfaces.
  c.bg_search = blend("#528BFF", 0x3D / 0xFF, BG) -- editor.findMatchHighlightBackground #528BFF3D
  c.whitespace = blend("#ABB2BF", 0x26 / 0xFF, BG) -- editorWhitespace.foreground #ABB2BF26
  c.word_highlight = blend("#D2E0FF", 0x2F / 0xFF, BG) -- editor.wordHighlightBackground
  c.word_highlight_strong = c.whitespace -- editor.wordHighlightStrongBackground #ABB2BF26

  -- Borders: editorGroup.border is #00000030 and focusBorder is #000000, both
  -- invisible on a black editor, so borders fall back to the theme's visible
  -- widget border instead of reproducing the invisibility.
  c.border = "#3A3F4B" -- editorWidget.border

  -- Text
  c.fg = "#ABB2BF" -- editor.foreground
  c.fg_dark = "#9DA5B4" -- statusBar.foreground
  c.fg_gutter = "#636D83" -- editorLineNumber.foreground
  c.cursor = "#528BFF" -- editorCursor.foreground
  c.comment = "#5C6370" -- tokenColors: comment (pre-#7F848E One Dark Pro)
  c.gray = "#5C6370" -- tokenColors: markup.quote, comment markup.link
  c.error = "#E05252" -- invalid.illegal background (theme sets no editorError.foreground)

  -- The theme defines no delete/change backgrounds at all (only
  -- diffEditor.insertedTextBackground), so keep atom-one's tuned alphas and
  -- re-composite them on black.
  c.diff = {
    add = blend("#00809B", 0.35, BG),
    delete = blend("#9A353D", 0.42, BG),
    change = blend("#D19A66", 0.28, BG),
    text = blend("#61AFEF", 0.32, BG),
  }

  -- c.terminal is left as-is: Atom One Dark's 16 ANSI colors are the ones
  -- wezterm's atom-just-black.toml and herdr-app's theme also use.
end

---@param hl table
function M.on_highlights(hl)
  -- Groups whose palette source is deliberately near-black in VS Code, but
  -- which nvim reuses for something that would become unreadable.
  hl.PmenuSel = { bg = "#2C313A" } -- editorSuggestWidget.selectedBackground
  hl.PmenuThumb = { bg = blend("#4E5666", 0x80 / 0xFF, BG) } -- scrollbarSlider.background
  hl.ColorColumn = { bg = blend("#ABB2BF", 0x26 / 0xFF, BG) } -- editorRuler.foreground

  -- Chrome the palette cannot reach without a dedicated field
  hl.TabLine = { fg = "#7D7D80", bg = BG } -- sideBar.foreground
  hl.TabLineFill = { bg = BG }
  hl.TabLineSel = { fg = "#D7DAE0", bg = BG } -- tab.activeForeground
  hl.WinSeparator = { fg = "#242323" } -- sideBar.border
  hl.MatchParen = { fg = "#FFFFFF", bg = "#3E4451", bold = true } -- editorBracketMatch.background
  hl.Substitute = { fg = BG, bg = "#E06C75" }
end

return M
