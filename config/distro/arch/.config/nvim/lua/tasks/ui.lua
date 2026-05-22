local date = require("tasks.date")
local rollover = require("tasks.rollover")
local store = require("tasks.store")

local M = {}

function M.open_today(opts)
  opts = opts or {}
  local today = opts.today or date.today()
  store.ensure_daily(today)
  rollover.rollover(today)
  local daily_path = store.daily_path(today)
  vim.cmd("edit " .. vim.fn.fnameescape(daily_path))

  return daily_path
end

return M
