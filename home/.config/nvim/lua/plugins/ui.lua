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
      delay_event_to_smear = 50,  -- ms; default 1 draws the trail before the cursor position settles, causing upward flicks while typing
    },
  },
  {
    'sitiom/nvim-numbertoggle',
    event = 'VeryLazy',  -- absolute numbers in insert mode / unfocused windows, relative otherwise
  },
}
