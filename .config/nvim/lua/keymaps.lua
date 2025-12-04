-- Indent while in visual mode.
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Open package manager.
vim.keymap.set('n', '<leader>L', '<cmd>Lazy<cr>', { desc = 'Open Lazy' })

-- Switch between windows
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window', remap = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window', remap = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top window', remap = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window', remap = true })

-- Tab navigation
vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<cr>', { desc = 'Close tab' })
vim.keymap.set('n', '<leader>tn', '<cmd>tab split<cr>', { desc = 'New tab' })
vim.keymap.set('n', '<leader>to', '<cmd>tabonly<cr>', { desc = 'Close other tabs' })
