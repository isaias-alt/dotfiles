return {
  'obsidian-nvim/obsidian.nvim',
  version = '*',
  ft = 'markdown',
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false,
    workspaces = {
      { name = 'Ideaverse', path = '~/Desktop/Ideaverse' },
    },
    picker = { name = 'snacks.picker' },
  },
  keys = {
    { '<leader>i', function() Snacks.image.hover() end, desc = 'Preview Image Under Cursor' },
  },
}
