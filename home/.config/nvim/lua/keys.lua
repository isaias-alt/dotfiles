-- select all
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })
-- pasting over a selection no longer clobbers your clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])

-- insert mode: option+arrows jump words
vim.keymap.set('i', '<M-Left>', '<C-Left>', { desc = 'Word back' })
vim.keymap.set('i', '<M-Right>', '<C-Right>', { desc = 'Word forward' })
