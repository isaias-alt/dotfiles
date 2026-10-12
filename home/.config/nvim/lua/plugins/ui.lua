return {
  {
    'folke/which-key.nvim',
    lazy = false,
    config = true,  -- popup that shows what my leader keys do
  },
  {
    'sphamba/smear-cursor.nvim',
    event = 'VeryLazy',
    opts = {  -- animated trail when the cursor jumps
      smear_insert_mode = false,  -- no trail while typing, it flicked upward on every keystroke
    },
  },
  {
    'sitiom/nvim-numbertoggle',
    event = 'VeryLazy',  -- absolute numbers in insert mode / unfocused windows, relative otherwise
  },
}
