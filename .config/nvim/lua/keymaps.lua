vim.g.mapleader = ' '

-- Search
vim.keymap.set('n', '<leader>/', '<cmd>noh<cr>', { desc = 'Clear highlighting' })


-- Quit
vim.keymap.set('n', '<leader>qq', '<cmd>qall!<cr>', { desc = 'Quit all without saving' })


-- Buffer navigation
vim.keymap.set('n', 'H', '<cmd>bprevious<cr>', { desc = 'Go to previous buffer' })
vim.keymap.set('n', 'L', '<cmd>bnext<cr>', { desc = 'Go to next buffer' })


-- Split windows
vim.keymap.set('n', '<leader>-', '<C-w>s', { desc = 'Split window horizontally' })
vim.keymap.set('n', '<leader>\\', '<C-w>v', { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>wc', '<C-w>q', { desc = 'Close current window' })


-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to window below' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to window above' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })



