return {
  'obsidian-nvim/obsidian.nvim',
  version = '*',
  ft = 'markdown',
  init = function()
    -- required for obsidian.nvim's concealed syntax (wikilinks, checkboxes, bold/italic)
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'markdown',
      callback = function() vim.opt_local.conceallevel = 2 end,
    })
  end,
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
