local config = require("tasks.config")
local parser = require("tasks.parser")
local store = require("tasks.store")

local M = {}

local function read_frontmatter(path)
  local lines = vim.fn.readfile(path)
  if lines[1] ~= "---" then
    return {}
  end

  local values = {}
  local index = 2
  while index <= #lines and lines[index] ~= "---" do
    local key, value = lines[index]:match("^([%w_]+):%s*(.+)$")
    if key then
      values[key] = value
    end
    index = index + 1
  end

  return values
end

local function sql_quote(value)
  if value == nil or value == "" then
    return "NULL"
  end

  return "'" .. tostring(value):gsub("'", "''") .. "'"
end

function M.refresh()
  if vim.fn.executable("sqlite3") ~= 1 then
    vim.notify("sqlite3 is not available; skipping task index refresh", vim.log.levels.WARN)
    return false
  end

  local db_path = config.get().db_path
  vim.fn.mkdir(vim.fn.fnamemodify(db_path, ":h"), "p")

  local task_rows = {}
  local occurrence_rows = {}
  local weekly_rows = {}
  local seen = {}

  for _, path in ipairs(store.list_daily_paths()) do
    local doc = store.load_daily_path(path)
    if doc then
      for _, task in ipairs(parser.iter_tasks(doc)) do
        if not seen[task.id] then
          seen[task.id] = true
          task_rows[#task_rows + 1] = string.format(
            "INSERT OR REPLACE INTO tasks (id, description, scope, project, added_date) VALUES (%s, %s, %s, %s, %s);",
            sql_quote(task.id),
            sql_quote(task.description),
            sql_quote(task.scope),
            sql_quote(task.project),
            sql_quote(task.added)
          )
        end

        occurrence_rows[#occurrence_rows + 1] = string.format(
          "INSERT INTO task_occurrences (task_id, file_date, status, completed_date, source_file) VALUES (%s, %s, %s, %s, %s);",
          sql_quote(task.id),
          sql_quote(doc.date),
          sql_quote(task.done and "done" or "open"),
          sql_quote(task.completed),
          sql_quote(path)
        )
      end
    end
  end

  local weekly_paths = vim.fn.globpath(config.get().root, "weekly/????/week-??.md", false, true)
  table.sort(weekly_paths)
  for _, path in ipairs(weekly_paths) do
    local frontmatter = read_frontmatter(path)
    if frontmatter.week and frontmatter.range_start and frontmatter.range_end and frontmatter.generated_at then
      weekly_rows[#weekly_rows + 1] = string.format(
        "INSERT INTO weekly_summaries (week_key, range_start, range_end, summary_path, generated_at) VALUES (%s, %s, %s, %s, %s);",
        sql_quote(frontmatter.week),
        sql_quote(frontmatter.range_start),
        sql_quote(frontmatter.range_end),
        sql_quote(path),
        sql_quote(frontmatter.generated_at)
      )
    end
  end

  local sql = {
    "PRAGMA journal_mode=WAL;",
    "CREATE TABLE IF NOT EXISTS tasks (id TEXT PRIMARY KEY, description TEXT NOT NULL, scope TEXT NOT NULL, project TEXT NOT NULL, added_date TEXT NOT NULL);",
    "CREATE TABLE IF NOT EXISTS task_occurrences (task_id TEXT NOT NULL, file_date TEXT NOT NULL, status TEXT NOT NULL, completed_date TEXT, source_file TEXT NOT NULL);",
    "CREATE TABLE IF NOT EXISTS weekly_summaries (week_key TEXT PRIMARY KEY, range_start TEXT NOT NULL, range_end TEXT NOT NULL, summary_path TEXT NOT NULL, generated_at TEXT NOT NULL);",
    "DELETE FROM tasks;",
    "DELETE FROM task_occurrences;",
    "DELETE FROM weekly_summaries;",
  }

  vim.list_extend(sql, task_rows)
  vim.list_extend(sql, occurrence_rows)
  vim.list_extend(sql, weekly_rows)

  local temp_path = vim.fn.tempname()
  vim.fn.writefile(sql, temp_path)
  local result = vim.system({ "sh", "-c", "sqlite3 \"$1\" < \"$2\"", "sh", db_path, temp_path }, {
    text = true,
  }):wait()
  vim.fn.delete(temp_path)

  if result.code ~= 0 then
    vim.notify("Task index refresh failed: " .. vim.trim(result.stderr or ""), vim.log.levels.ERROR)
    return false
  end

  return true
end

return M
