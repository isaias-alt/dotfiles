vim.diagnostic.config({
  underline = true,
  severity_sort = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 4,
    source = 'if_many',
    prefix = '●',
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.HINT] = '',
    },
  },
})

-- one lsp server per filetype in treesitter.lua, so both configs travel together
local servers = {
  'astro',      -- astro
  'bashls',     -- bash
  'cssls',      -- css
  'gopls',      -- go
  'html',       -- html
  'jsonls',     -- json, jsonc
  'lua_ls',     -- lua
  'marksman',   -- markdown
  'taplo',      -- toml
  'ts_ls',      -- javascript(react), typescript(react)
  'yamlls',     -- yaml
}

return {
  { 'mason-org/mason.nvim', opts = {} },
  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = { 'mason-org/mason.nvim', 'neovim/nvim-lspconfig' },
    opts = { ensure_installed = servers },
  },
  { 'neovim/nvim-lspconfig' },
}
