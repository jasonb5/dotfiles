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


-- Window resizing
vim.keymap.set('n', '<M-h>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease window width' })
vim.keymap.set('n', '<M-j>', '<cmd>resize -2<cr>', { desc = 'Decrease window height' })
vim.keymap.set('n', '<M-k>', '<cmd>resize +2<cr>', { desc = 'Increase window height' })
vim.keymap.set('n', '<M-l>', '<cmd>vertical resize +2<cr>', { desc = 'Increase window width' })

vim.keymap.set('n', '<leader>ft', function()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)

  local winopt = {
    border = 'double',
    col = col,
    height = height,
    relative = 'editor',
    row = row,
    style = 'minimal',
    width = width,
  }

  local win = vim.api.nvim_open_win(buf, true, winopt)
  vim.bo[buf].bufhidden = 'wipe'
  vim.wo[win].winblend = 0
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'

  vim.fn.jobstart(vim.o.shell, { term = true })
  vim.cmd('startinsert')
end, { desc = 'Open a floating terminal' })

