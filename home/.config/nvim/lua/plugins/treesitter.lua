local filetypes = {
  'astro',
  'bash',
  'css',
  'go',
  'html',
  'javascript',
  'javascriptreact',
  'json',
  'jsonc',
  'lua',
  'markdown',
  'mdx',
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
  'go',
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

      -- same for mdx: detect the extension and reuse the markdown grammar
      vim.filetype.add({ extension = { mdx = 'mdx' } })
      vim.treesitter.language.register('markdown', 'mdx')

      vim.api.nvim_create_autocmd('FileType', {
        pattern = filetypes,
        callback = function()
          vim.treesitter.start()
        end,
      })
    end,
  },
}
