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

-- Buffer navigation
vim.keymap.set('n', 'H', '<cmd>bprevious<cr>', { desc = 'Go to previous buffer' })
vim.keymap.set('n', 'L', '<cmd>bnext<cr>', { desc = 'Go to next buffer' })

-- Open terminal in floating window
vim.keymap.set('n', '<leader>ft', function()
  -- Improved floating terminal
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = 'rounded',
  })

  -- Set buffer/window options for terminal UX
  vim.api.nvim_set_option_value('number', false, { win = win })
  vim.api.nvim_set_option_value('relativenumber', false, { win = win })
  vim.api.nvim_set_option_value('signcolumn', 'no', { win = win })

  -- Open terminal attached to the buffer & win
  vim.fn.termopen(vim.o.shell, {
    on_exit = function()
      -- Automatically close the window and buffer
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  })
  vim.cmd('startinsert!')

  -- Map <Esc> to exit terminal and close
  vim.keymap.set('t', '<Esc>', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })
end, { desc = 'Floating Terminal' })

-- Tab navigation
vim.keymap.set('n', '<leader>tc', '<cmd>tabclose<cr>', { desc = 'Close tab' })
vim.keymap.set('n', '<leader>tn', '<cmd>tab split<cr>', { desc = 'New tab' })
vim.keymap.set('n', '<leader>to', '<cmd>tabonly<cr>', { desc = 'Close other tabs' })
