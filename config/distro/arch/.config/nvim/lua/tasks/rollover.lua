local parser = require("tasks.parser")
local date = require("tasks.date")
local store = require("tasks.store")

local M = {}

local function latest_previous_doc(day)
  local previous_path = store.find_previous_daily(day)
  if not previous_path then
    return nil
  end

  return store.load_daily_path(previous_path)
end

local function open_previous_tasks(day)
  local doc = latest_previous_doc(day)
  if not doc then
    return {}
  end

  local out = {}
  for _, task in ipairs(parser.iter_tasks(doc)) do
    if not task.done then
      out[task.id] = task
    end
  end

  return out
end

function M.rollover(day)
  local today_doc = store.ensure_daily(day)
  local previous_open = open_previous_tasks(day)

  local added = 0
  for _, task in pairs(previous_open) do
    if not parser.has_task_id(today_doc, task.id) then
      parser.add_task(today_doc, task.scope, task.project, {
        id = task.id,
        description = task.description,
        added = task.added,
        done = false,
      })
      added = added + 1
    end
  end

  if added > 0 then
    store.save_daily(today_doc)
  end

  return added
end

function M.regenerate(day)
  local today_doc = store.ensure_daily(day)
  local previous_open = open_previous_tasks(day)
  local rebuilt = parser.new_daily(day)
  local changed = false

  for _, task in ipairs(parser.iter_tasks(today_doc)) do
    if task.done or task.added == day then
      parser.add_task(rebuilt, task.scope, task.project, {
        id = task.id,
        description = task.description,
        added = task.added,
        done = task.done,
        completed = task.completed,
      })
    end
  end

  for _, task in pairs(previous_open) do
    if not parser.has_task_id(rebuilt, task.id) then
      parser.add_task(rebuilt, task.scope, task.project, {
        id = task.id,
        description = task.description,
        added = task.added,
        done = false,
      })
    end
  end

  local current_by_id = {}
  for _, task in ipairs(parser.iter_tasks(today_doc)) do
    current_by_id[task.id .. ":" .. task.scope .. ":" .. task.project .. ":" .. tostring(task.done)] = task
  end

  for _, task in ipairs(parser.iter_tasks(rebuilt)) do
    local key = task.id .. ":" .. task.scope .. ":" .. task.project .. ":" .. tostring(task.done)
    if not current_by_id[key] then
      changed = true
      break
    end
    current_by_id[key] = nil
  end

  if not changed and next(current_by_id) ~= nil then
    changed = true
  end

  if changed then
    store.save_daily(rebuilt)
  end

  return changed
end

return M
