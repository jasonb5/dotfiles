local parser = require("tasks.parser")
local store = require("tasks.store")

local M = {}

function M.rollover(day)
  local today_doc = store.ensure_daily(day)
  local previous_path = store.find_previous_daily(day)
  if not previous_path then
    return 0
  end

  local previous_doc = store.load_daily_path(previous_path)
  if not previous_doc then
    return 0
  end

  local added = 0
  for _, task in ipairs(parser.iter_tasks(previous_doc)) do
    if not task.done and not parser.has_task_id(today_doc, task.id) then
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

return M
