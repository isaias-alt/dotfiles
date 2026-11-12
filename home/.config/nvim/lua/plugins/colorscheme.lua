return {
  {
    'isaias-alt/atom-one.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      local just_black = require('atom_just_black')

      -- Atom One Dark syntax colors with the Just Black (#000000) UI chrome
      -- ported from the VS Code extension; see lua/atom_just_black.lua for the
      -- per-color ground truth.
      require('atom-one').setup({
        variant = 'onedark',
        -- The theme already paints #000000, which is exactly what wezterm has,
        -- so there is no double-blend to avoid: keep the explicit background.
        transparent = false,
        on_colors = just_black.on_colors,
        on_highlights = just_black.on_highlights,
      })

      vim.cmd.colorscheme('atom-one')
    end,
  },
  {
    'craftzdog/solarized-osaka.nvim',
    lazy = true,
    config = function()
      require('solarized-osaka').setup({
        transparent = true,
      })
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = true,
    config = function()
      require('catppuccin').setup({
        flavour = 'macchiato',
        transparent_background = true,
      })
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
    'folke/tokyonight.nvim',
    lazy = true,
    config = function()
      require('tokyonight').setup({
        style = 'night',
        transparent = true,
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
