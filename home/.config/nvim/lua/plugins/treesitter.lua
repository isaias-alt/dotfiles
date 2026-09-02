local filetypes = {
  'astro',
  'bash',
  'css',
  'html',
  'javascript',
  'javascriptreact',
  'json',
  'jsonc',
  'lua',
  'markdown',
  'toml',
  'typescript',
  'typescriptreact',
  'vim',
  'yaml',
}

local parsers = {
  'astro',
  'bash',
  'css',
  'html',
  'javascript',
  'jsdoc',
  'json',
  'lua',
  'markdown',
  'markdown_inline',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'main',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install(parsers)

      -- jsonc has no separate parser; reuse the json grammar for it
      vim.treesitter.language.register('json', 'jsonc')

      vim.api.nvim_create_autocmd('FileType', {
        pattern = filetypes,
        callback = function()
          vim.treesitter.start()
        end,
      })
    end,
  },
}
