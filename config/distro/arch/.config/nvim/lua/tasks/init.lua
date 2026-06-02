local config = require("tasks.config")
local date = require("tasks.date")
local index = require("tasks.index")
local parser = require("tasks.parser")
local prompts = require("tasks.prompts")
local rollover = require("tasks.rollover")
local store = require("tasks.store")
local ui = require("tasks.ui")

local M = {}

local function open_path(path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

local function recent_task_entries()
  local root = require("tasks.config").get().root
  local entries = {}

  for _, path in ipairs(store.list_daily_paths()) do
    local stat = vim.uv.fs_stat(path)
    if stat then
      entries[#entries + 1] = {
        path = path,
        relative = vim.fs.relpath(root, path) or path,
        mtime = stat.mtime.sec,
      }
    end
  end

  table.sort(entries, function(left, right)
    if left.mtime == right.mtime then
      return left.relative < right.relative
    end
    return left.mtime > right.mtime
  end)

  return entries
end

function M.setup(opts)
  math.randomseed(os.time())
  config.setup(opts)
end

function M.open_today()
  local path = ui.open_today()
  pcall(index.refresh)
  return path
end

function M.open_recent_picker()
  local ok, fzf = pcall(require, "fzf-lua")
  if not ok then
    vim.notify("fzf-lua is not available", vim.log.levels.ERROR)
    return
  end

  local entries = recent_task_entries()
  local lookup = {}
  local items = {}

  for _, entry in ipairs(entries) do
    local label = string.format("%s  %s", os.date("%Y-%m-%d %H:%M", entry.mtime), entry.relative)
    lookup[label] = entry.path
    items[#items + 1] = label
  end

  fzf.fzf_exec(items, {
    prompt = "Recent Tasks> ",
    actions = {
      ["default"] = function(selected)
        local choice = selected and selected[1]
        local path = choice and lookup[choice] or nil
        if path then
          open_path(path)
        end
      end,
    },
  })
end

function M.add_task()
  local bufnr = vim.api.nvim_get_current_buf()
  local path = store.path_for_buffer(bufnr)
  local target_day = date.today()

  if path ~= "" and store.is_daily_path(path) then
    target_day = store.date_for_path(path) or target_day
  end

  prompts.add_task(target_day, function(path)
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

function M.regenerate_today()
  local today = date.today()
  local changed = rollover.regenerate(today)
  local today_path = store.daily_path(today)

  if store.path_for_buffer(0) == today_path then
    vim.cmd("edit")
  end

  pcall(index.refresh)
  if changed then
    vim.notify("Today's tasks regenerated", vim.log.levels.INFO)
  else
    vim.notify("Today's tasks were already up to date", vim.log.levels.INFO)
  end
end

return M
