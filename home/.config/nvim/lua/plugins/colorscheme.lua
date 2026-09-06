return {
  {
    'isaias-alt/atom-one.nvim',
    lazy = false,
    priority = 1000,
    dependencies = { 'folke/tokyonight.nvim' },
    config = function()
      vim.cmd.colorscheme('atom-one-night-flat')

      -- Let WezTerm's own background (and text_background_opacity) show
      -- through instead of nvim painting its own solid bg per cell - that
      -- explicit paint is what compounds with window opacity into a visible
      -- mismatch (see wezterm.lua's text_background_opacity comment).
      for _, group in ipairs({ 'Normal', 'NormalNC', 'SignColumn', 'EndOfBuffer', 'LineNr' }) do
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        hl.bg = nil
        vim.api.nvim_set_hl(0, group, hl)
      end
    end,
  },
  {
    'sainnhe/sonokai',
    lazy = true,
    config = function()
      vim.g.sonokai_style = 'default'
      vim.cmd.colorscheme('sonokai')
    end,
  },
  {
    'craftzdog/solarized-osaka.nvim',
    lazy = true,
    config = function()
      require('solarized-osaka').setup({})
    end,
  },
  {
    'folke/tokyonight.nvim',
    lazy = true,
    config = function()
      require('tokyonight').setup({
        style = 'night',
      })
    end,
  },
  {
    'olimorris/onedarkpro.nvim',
    lazy = true,
    config = function()
      require('onedarkpro').setup({
        theme = 'onedark_dark',
      })
    end,
  },
  {
    'rose-pine/neovim',
    lazy = true,
    name = 'rose-pine',
    config = function()
      require('rose-pine').setup({
        dark_variant = 'moon',
        dim_inactive_windows = false,
        extend_background_behind_borders = false,
        styles = {
          italic = false,
        },
      })

      -- Make the dimmed directory path in the Snacks picker readable
      local palette = require('rose-pine.palette')
      vim.api.nvim_set_hl(0, 'SnacksPickerDir', { fg = palette.subtle })
    end,
  },
}
