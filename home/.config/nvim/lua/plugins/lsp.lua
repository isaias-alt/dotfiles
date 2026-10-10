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
  'emmet_language_server', -- html/jsx abbreviations (div.card>ul>li*3)
  'eslint',     -- javascript(react), typescript(react)
  'gopls',      -- go
  'html',       -- html
  'jsonls',     -- json, jsonc
  'lua_ls',     -- lua
  'marksman',   -- markdown
  'mdx_analyzer', -- mdx
  'taplo',      -- toml
  'tailwindcss', -- class completion + lint (e.g. max-w-[480px] -> max-w-120)
  'ts_ls',      -- javascript(react), typescript(react)
  'yamlls',     -- yaml
}

-- include files behind the `eval` build tag (vexillum internal/tribunal/eval_test.go)
vim.lsp.config('gopls', {
  settings = { gopls = { buildFlags = { '-tags=eval' } } },
})

vim.keymap.set({ 'n', 'x' }, '<leader>a', vim.lsp.buf.code_action, { desc = 'Code Action (quick fix)' })

return {
  { 'mason-org/mason.nvim', opts = {} },
  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = { 'mason-org/mason.nvim', 'neovim/nvim-lspconfig' },
    opts = {
      ensure_installed = servers,
      -- only the servers listed above run; anything else left in mason (biome, dockerls...) stays off
      automatic_enable = false,
    },
    config = function(_, opts)
      require('mason-lspconfig').setup(opts)
      vim.lsp.enable(servers)
    end,
  },
  { 'neovim/nvim-lspconfig' },
}
