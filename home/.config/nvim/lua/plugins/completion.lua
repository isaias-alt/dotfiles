return {
  {
    'saghen/blink.cmp',
    lazy = false,
    version = '1.*',  -- tagged releases ship a prebuilt fuzzy matcher, no rust toolchain needed
    opts = {
      keymap = { preset = 'enter' },  -- enter accepts, tab jumps snippet placeholders
      completion = {
        documentation = { auto_show = true },  -- docs popup next to the menu
      },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
    },
    config = function(_, opts)
      require('blink.cmp').setup(opts)
      -- tell every lsp server that completion goes through blink
      vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })
    end,
  },
  {
    'windwp/nvim-autopairs',  -- closes ( [ { ' "
    event = 'InsertEnter',
    opts = { check_ts = true },
  },
  {
    'windwp/nvim-ts-autotag',  -- closes and renames html/jsx tags
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },
}
