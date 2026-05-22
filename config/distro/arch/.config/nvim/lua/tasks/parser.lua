local M = {}

local scopes = { "Work", "Personal" }

local function new_scope()
  return {
    project_order = {},
    projects = {},
  }
end

function M.new_daily(date)
  return {
    kind = "daily",
    date = date,
    scopes = {
      Work = new_scope(),
      Personal = new_scope(),
    },
  }
end

local function ensure_project(doc, scope_name, project_name)
  local scope = doc.scopes[scope_name]
  if not scope.projects[project_name] then
    scope.projects[project_name] = { name = project_name, tasks = {} }
    scope.project_order[#scope.project_order + 1] = project_name
  end

  return scope.projects[project_name]
end

function M.ensure_project(doc, scope_name, project_name)
  return ensure_project(doc, scope_name, project_name)
end

function M.add_task(doc, scope_name, project_name, task)
  local project = ensure_project(doc, scope_name, project_name)
  project.tasks[#project.tasks + 1] = task
  return task
end

function M.iter_tasks(doc)
  local out = {}

  for _, scope_name in ipairs(scopes) do
    local scope = doc.scopes[scope_name]
    for _, project_name in ipairs(scope.project_order) do
      local project = scope.projects[project_name]
      for _, task in ipairs(project.tasks) do
        task.scope = scope_name
        task.project = project_name
        out[#out + 1] = task
      end
    end
  end

  return out
end

function M.has_task_id(doc, task_id)
  for _, task in ipairs(M.iter_tasks(doc)) do
    if task.id == task_id then
      return true
    end
  end

  return false
end

function M.find_task_by_line(doc, line_number)
  for _, task in ipairs(M.iter_tasks(doc)) do
    if task.line_start and task.line_end and line_number >= task.line_start and line_number <= task.line_end then
      return task
    end
  end
end

function M.find_task_by_id(doc, task_id)
  for _, task in ipairs(M.iter_tasks(doc)) do
    if task.id == task_id then
      return task
    end
  end
end

local function parse_frontmatter(lines, start_index)
  local frontmatter = {}
  local index = start_index

  if lines[index] ~= "---" then
    return frontmatter, index
  end

  index = index + 1
  while index <= #lines and lines[index] ~= "---" do
    local key, value = lines[index]:match("^([%w_]+):%s*(.+)$")
    if key then
      frontmatter[key] = value
    end
    index = index + 1
  end

  if lines[index] == "---" then
    index = index + 1
  end

  if lines[index] == "" then
    index = index + 1
  end

  return frontmatter, index
end

function M.parse_daily(text, fallback_date)
  local lines = vim.split(text or "", "\n", { plain = true })
  local frontmatter, index = parse_frontmatter(lines, 1)
  local doc = M.new_daily(frontmatter.date or fallback_date)
  local current_scope = nil
  local current_project = nil

  while index <= #lines do
    local line = lines[index]
    local title_date = line:match("^# (%d%d%d%d%-%d%d%-%d%d)$")
    if title_date then
      doc.date = title_date
    end

    local scope_name = line:match("^## (.+)$")
    if scope_name and doc.scopes[scope_name] then
      current_scope = scope_name
      current_project = nil
      index = index + 1
    else
      local project_name = line:match("^### (.+)$")
      if project_name and current_scope then
        current_project = project_name
        ensure_project(doc, current_scope, current_project)
        index = index + 1
      else
        local mark, description = line:match("^- %[(.)%] (.+)$")
        if mark and current_scope then
          current_project = current_project or "Inbox"
          local task = {
            done = mark:lower() == "x",
            description = description,
            line_start = index,
            line_end = index,
          }

          index = index + 1
          while index <= #lines do
            local key, value = lines[index]:match("^  %- ([%w_]+):%s*(.+)$")
            if not key then
              break
            end

            task[key] = value
            task.line_end = index
            index = index + 1
          end

          task.id = task.id or ""
          task.added = task.added or doc.date
          M.add_task(doc, current_scope, current_project, task)
        else
          index = index + 1
        end
      end
    end
  end

  return doc
end

function M.render_daily(doc)
  local lines = {
    "---",
    "date: " .. doc.date,
    "type: daily-tasks",
    "---",
    "",
    "# " .. doc.date,
    "",
  }

  for _, scope_name in ipairs(scopes) do
    local scope = doc.scopes[scope_name]
    lines[#lines + 1] = "## " .. scope_name
    lines[#lines + 1] = ""

    for _, project_name in ipairs(scope.project_order) do
      local project = scope.projects[project_name]
      lines[#lines + 1] = "### " .. project_name
      for _, task in ipairs(project.tasks) do
        lines[#lines + 1] = string.format("- [%s] %s", task.done and "x" or " ", task.description)
        lines[#lines + 1] = "  - id: " .. task.id
        lines[#lines + 1] = "  - added: " .. task.added
        if task.completed then
          lines[#lines + 1] = "  - completed: " .. task.completed
        end
      end
      lines[#lines + 1] = ""
    end
  end

  while lines[#lines] == "" do
    lines[#lines] = nil
  end

  return table.concat(lines, "\n") .. "\n"
end

return M
