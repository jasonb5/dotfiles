vim.api.nvim_create_user_command('FloatingTerminal', function()
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
  vim.bo[buf].buflisted = false
  vim.wo[win].winblend = 0
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'

  vim.api.nvim_create_autocmd('TermClose', {
    buffer = buf,
    once = true,
    callback = function()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end)
    end,
  })

  vim.fn.jobstart(vim.o.shell, { term = true })
  vim.cmd('startinsert')
end, { desc = 'Open a floating terminal' })

