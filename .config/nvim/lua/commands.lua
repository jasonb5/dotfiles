local floating_terminal = {
  last_buf = nil,
}

local function first_window_for_buffer(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return nil
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
      return win
    end
  end

  return nil
end

local function ensure_codecompanion_loaded()
  if vim.fn.exists(':CodeCompanionChat') == 2 then
    return true
  end

  local ok, lazy = pcall(require, 'lazy')
  if ok then
    lazy.load({ plugins = { 'codecompanion.nvim' } })
  end

  return vim.fn.exists(':CodeCompanionChat') == 2
end

local function terminal_lines(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return nil
  end

  if vim.bo[buf].buftype ~= 'terminal' then
    return nil
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i, line in ipairs(lines) do
    lines[i] = line:gsub('\r', '')
  end

  while #lines > 0 and lines[1] == '' do
    table.remove(lines, 1)
  end
  while #lines > 0 and lines[#lines] == '' do
    table.remove(lines, #lines)
  end

  return lines
end

local function terminal_line_count(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return 0
  end

  local count = vim.api.nvim_buf_line_count(buf)
  if count == 1 then
    local first = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
    if first == '' then
      return 0
    end
  end

  return count
end

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
  floating_terminal.last_buf = buf
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].buflisted = false
  vim.wo[win].winblend = 0
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = 'no'

  local function update_terminal_winbar()
    if not vim.api.nvim_win_is_valid(win) or not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    vim.wo[win].winbar = ' FloatTerm [' .. terminal_line_count(buf) .. ' lines] '
  end

  update_terminal_winbar()
  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function()
      vim.schedule(update_terminal_winbar)
    end,
  })

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

local function send_terminal_to_codecompanion(max_lines)
  if not ensure_codecompanion_loaded() then
    vim.notify('CodeCompanion is not available', vim.log.levels.ERROR)
    return
  end

  local buf = nil
  local terminal_win = nil
  if vim.bo[0].buftype == 'terminal' then
    buf = vim.api.nvim_get_current_buf()
    terminal_win = vim.api.nvim_get_current_win()
  else
    buf = floating_terminal.last_buf
    terminal_win = first_window_for_buffer(buf)
  end

  local lines = terminal_lines(buf)
  if not lines then
    vim.notify('No floating terminal buffer found', vim.log.levels.WARN)
    return
  end

  if #lines == 0 then
    vim.notify('Terminal has no output to send', vim.log.levels.INFO)
    return
  end

  local start_idx = 1
  if max_lines > 0 then
    start_idx = math.max(1, #lines - max_lines + 1)
  end
  local payload = {}
  if start_idx > 1 then
    table.insert(payload, '[truncated to last ' .. max_lines .. ' lines]')
    table.insert(payload, '')
  end
  for i = start_idx, #lines do
    table.insert(payload, lines[i])
  end

  vim.cmd('CodeCompanionChat Toggle')

  local scratch = vim.api.nvim_create_buf(false, true)
  vim.bo[scratch].bufhidden = 'wipe'
  vim.api.nvim_buf_set_lines(scratch, 0, -1, false, payload)

  vim.api.nvim_buf_call(scratch, function()
    vim.cmd('silent 1,$CodeCompanionChat Add')
  end)

  if vim.api.nvim_buf_is_valid(scratch) then
    vim.api.nvim_buf_delete(scratch, { force = true })
  end

  if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
    vim.api.nvim_set_current_win(terminal_win)
    if vim.bo[vim.api.nvim_win_get_buf(terminal_win)].buftype == 'terminal' then
      vim.cmd('startinsert')
    end
  end
end

vim.api.nvim_create_user_command('FloatingTerminalToCodeCompanion', function(opts)
  if opts.args == 'all' then
    send_terminal_to_codecompanion(0)
    return
  end

  if opts.args ~= '' then
    local parsed = tonumber(opts.args)
    if parsed and parsed > 0 then
      send_terminal_to_codecompanion(math.floor(parsed))
    else
      vim.notify('Argument must be a positive integer or "all"', vim.log.levels.ERROR)
    end
    return
  end

  local default_lines = 300
  if type(vim.g.floating_terminal_codecompanion_max_lines) == 'number'
      and vim.g.floating_terminal_codecompanion_max_lines >= 0 then
    default_lines = math.floor(vim.g.floating_terminal_codecompanion_max_lines)
  end

  vim.ui.input({
    prompt = 'Lines to send (Enter=' .. default_lines .. ', or "all"): ',
  }, function(input)
    if not input then
      return
    end

    if input == '' then
      send_terminal_to_codecompanion(default_lines)
      return
    end

    if input == 'all' then
      send_terminal_to_codecompanion(0)
      return
    end

    local parsed = tonumber(input)
    if parsed and parsed > 0 then
      send_terminal_to_codecompanion(math.floor(parsed))
    else
      vim.notify('Value must be a positive integer or "all"', vim.log.levels.ERROR)
    end
  end)
end, {
  desc = 'Send floating terminal output to CodeCompanion chat',
  nargs = '?',
  complete = function()
    return { 'all' }
  end,
})
