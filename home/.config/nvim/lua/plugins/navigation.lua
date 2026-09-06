local dashboard_header = [[
██╗     ██╗   ██╗ ██████╗ █████╗ ███████╗ ██████╗ ██████╗ ██████╗ ███████╗██╗   ██╗
██║     ██║   ██║██╔════╝██╔══██╗██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔════╝██║   ██║
██║     ██║   ██║██║     ███████║███████╗██║     ██║   ██║██║  ██║█████╗  ██║   ██║
██║     ██║   ██║██║     ██╔══██║╚════██║██║     ██║   ██║██║  ██║██╔══╝  ╚██╗ ██╔╝
███████╗╚██████╔╝╚██████╗██║  ██║███████║╚██████╗╚██████╔╝██████╔╝███████╗ ╚████╔╝
╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝  ╚═══╝
]]

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true },
      notifier = { enabled = true },
      input = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = dashboard_header,
        },
      },
    },
    keys = {
      { '<leader>f', function() Snacks.picker.files() end, desc = 'Find Files' },
      { '<leader>s', function() Snacks.picker.grep() end,  desc = 'Search Text' },
      { '<leader>b', function() Snacks.picker.buffers() end, desc = 'Buffers' },
      { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
    },
    keys = {
      {
        '<leader>e',
        function()
          require('telescope').extensions.file_browser.file_browser({
            path = '%:p:h',
            cwd = vim.fn.expand('%:p:h'),
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            previewer = false,
            initial_mode = 'normal',
          })
        end,
        desc = 'File Browser',
      },
    },
    config = function()
      require('telescope').setup({
        defaults = {
          sorting_strategy = 'ascending',  -- read top-to-bottom: matches `grouped` (dirs first)
          layout_config = { prompt_position = 'top' },
        },
        extensions = {
          file_browser = {
            hijack_netrw = true,
          },
        },
      })
      require('telescope').load_extension('file_browser')
    end,
  },
}
