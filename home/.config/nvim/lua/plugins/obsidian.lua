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
    frontmatter = {
      -- keep `id` for stable renames/backlinks, but drop aliases/tags when empty
      func = function(note)
        local out = { id = note.id }
        if note.aliases and #note.aliases > 0 then out.aliases = note.aliases end
        if note.tags and #note.tags > 0 then out.tags = note.tags end
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do out[k] = v end
        end
        return out
      end,
    },
  },
  keys = {
    { '<leader>i', function() Snacks.image.hover() end, desc = 'Preview Image Under Cursor' },
    { '<leader>p', '<cmd>Obsidian paste_img<cr>', desc = 'Paste Image from Clipboard' },
  },
}
