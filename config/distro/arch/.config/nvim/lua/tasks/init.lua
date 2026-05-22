local config = require("tasks.config")
local date = require("tasks.date")
local index = require("tasks.index")
local parser = require("tasks.parser")
local prompts = require("tasks.prompts")
local store = require("tasks.store")
local ui = require("tasks.ui")

local M = {}

function M.setup(opts)
  math.randomseed(os.time())
  config.setup(opts)
end

function M.open_today()
  local path = ui.open_today()
  pcall(index.refresh)
  return path
end

function M.add_task()
  prompts.add_task(date.today(), function(path)
    vim.cmd("edit " .. vim.fn.fnameescape(path))
    pcall(index.refresh)
  end)
end

function M.toggle_current_task()
  local bufnr = vim.api.nvim_get_current_buf()
  local path = store.path_for_buffer(bufnr)
  if path == "" or not store.is_daily_path(path) then
    vim.notify("TaskToggle only works in a daily task file", vim.log.levels.WARN)
    return
  end

  if vim.bo[bufnr].modified then
    vim.cmd("write")
  end

  local doc = store.load_daily_path(path)
  if not doc then
    vim.notify("Could not parse task file", vim.log.levels.ERROR)
    return
  end

  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local task = parser.find_task_by_line(doc, line_number)
  if not task then
    vim.notify("No task found at cursor", vim.log.levels.WARN)
    return
  end

  task.done = not task.done
  task.completed = task.done and date.today() or nil
  store.save_daily(doc)
  vim.cmd("edit")
  pcall(index.refresh)
end

function M.refresh_index()
  if index.refresh() then
    vim.notify("Task index refreshed", vim.log.levels.INFO)
  end
end

return M
