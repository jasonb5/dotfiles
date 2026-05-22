local date = require("tasks.date")
local parser = require("tasks.parser")
local store = require("tasks.store")

local M = {}

local function context_defaults(bufnr, line_number)
  local path = store.path_for_buffer(bufnr)
  if path == "" or not store.is_daily_path(path) then
    return nil, nil
  end

  local doc = store.load_daily_path(path)
  if not doc then
    return nil, nil
  end

  local current_scope = nil
  local current_project = nil
  for _, task in ipairs(parser.iter_tasks(doc)) do
    if task.line_start and task.line_start <= line_number and task.line_end >= line_number then
      return task.scope, task.project
    end
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, line_number, false)
  for index = #lines, 1, -1 do
    local line = lines[index]
    local project = line:match("^### (.+)$")
    if project and not current_project then
      current_project = project
    end

    local scope = line:match("^## (.+)$")
    if scope == "Work" or scope == "Personal" then
      current_scope = scope
      break
    end
  end

  return current_scope, current_project
end

function M.add_task(day, callback)
  local bufnr = vim.api.nvim_get_current_buf()
  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local default_scope, default_project = context_defaults(bufnr, line_number)
  local scopes = { "Work", "Personal" }

  vim.ui.select(scopes, {
    prompt = "Task scope",
    format_item = function(item)
      return item
    end,
  }, function(scope)
    if not scope then
      return
    end

    vim.ui.input({
      prompt = "Project: ",
      default = default_project or "",
    }, function(project)
      if not project or vim.trim(project) == "" then
        return
      end

      vim.ui.input({
        prompt = "Task: ",
      }, function(description)
        if not description or vim.trim(description) == "" then
          return
        end

        local doc = store.ensure_daily(day)
        local task = {
          id = date.new_task_id(),
          description = vim.trim(description),
          added = day,
          done = false,
        }

        parser.add_task(doc, scope, vim.trim(project), task)
        store.save_daily(doc)

        if callback then
          callback(store.daily_path(day), task.id)
        end
      end)
    end)
  end)
end

return M
