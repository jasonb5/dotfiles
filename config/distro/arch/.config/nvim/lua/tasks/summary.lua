local config = require("tasks.config")
local date = require("tasks.date")
local parser = require("tasks.parser")
local store = require("tasks.store")

local M = {}

local function latest_occurrences(start_date, end_date)
  local by_id = {}
  local completed = {}

  for _, day in ipairs(date.range(start_date, end_date)) do
    local path = store.daily_path(day)
    if store.file_exists(path) then
      local doc = store.load_daily_path(path)
      for _, task in ipairs(parser.iter_tasks(doc)) do
        by_id[task.id] = {
          id = task.id,
          description = task.description,
          scope = task.scope,
          project = task.project,
          added = task.added,
          done = task.done,
          completed = task.completed,
          file_date = day,
        }

        if task.completed and task.completed >= start_date and task.completed <= end_date then
          completed[task.id] = {
            id = task.id,
            description = task.description,
            scope = task.scope,
            project = task.project,
            added = task.added,
            completed = task.completed,
          }
        end
      end
    end
  end

  return by_id, completed
end

local function grouped_lines(tasks, scope_name)
  local grouped = {}
  local order = {}

  for _, task in pairs(tasks) do
    if task.scope == scope_name then
      if not grouped[task.project] then
        grouped[task.project] = {}
        order[#order + 1] = task.project
      end
      grouped[task.project][#grouped[task.project] + 1] = task
    end
  end

  table.sort(order)
  local lines = {}
  for _, project in ipairs(order) do
    table.sort(grouped[project], function(left, right)
      return left.description < right.description
    end)

    lines[#lines + 1] = "### " .. project
    for _, task in ipairs(grouped[project]) do
      local suffix = task.completed and (" (completed: " .. task.completed .. ")") or (" (added: " .. task.added .. ")")
      lines[#lines + 1] = "- " .. task.description .. suffix
    end
    lines[#lines + 1] = ""
  end

  if #lines == 0 then
    return { "- None", "" }
  end

  return lines
end

local function render_summary(range_start, range_end, ai_summary, completed, open_tasks)
  local lines = {
    "---",
    "type: weekly-summary",
    "week: " .. date.week_key(range_start),
    "range_start: " .. range_start,
    "range_end: " .. range_end,
    "generated_at: " .. date.iso_timestamp(),
    "---",
    "",
    "# " .. date.week_title(range_start),
    "",
    "## AI Summary",
    ai_summary ~= "" and ai_summary or "Summary generation failed.",
    "",
    "## Work Completed By Project",
  }

  vim.list_extend(lines, grouped_lines(completed, "Work"))
  lines[#lines + 1] = "## Personal Completed By Project"
  vim.list_extend(lines, grouped_lines(completed, "Personal"))
  lines[#lines + 1] = "## Open Tasks"
  vim.list_extend(lines, grouped_lines(open_tasks, "Work"))
  lines[#lines + 1] = "## Open Personal Tasks"
  vim.list_extend(lines, grouped_lines(open_tasks, "Personal"))

  while lines[#lines] == "" do
    lines[#lines] = nil
  end

  return table.concat(lines, "\n") .. "\n"
end

local function build_prompt(range_start, range_end, completed, open_tasks)
  local lines = {
    "Write a concise weekly task summary in markdown.",
    "Focus on themes, progress, carry-over risk, and notable completed work.",
    "Do not invent facts.",
    "",
    "Range: " .. range_start .. " to " .. range_end,
    "",
    "Completed work:",
  }

  vim.list_extend(lines, grouped_lines(completed, "Work"))
  lines[#lines + 1] = "Completed personal tasks:"
  vim.list_extend(lines, grouped_lines(completed, "Personal"))
  lines[#lines + 1] = "Open work tasks:"
  vim.list_extend(lines, grouped_lines(open_tasks, "Work"))
  lines[#lines + 1] = "Open personal tasks:"
  vim.list_extend(lines, grouped_lines(open_tasks, "Personal"))

  return table.concat(lines, "\n")
end

local function extract_content(decoded)
  local choice = decoded and decoded.choices and decoded.choices[1]
  if not choice or not choice.message then
    return nil
  end

  local content = choice.message.content
  if type(content) == "string" then
    return content
  end

  if type(content) == "table" then
    local out = {}
    for _, chunk in ipairs(content) do
      if type(chunk) == "table" and chunk.text then
        out[#out + 1] = chunk.text
      end
    end
    return table.concat(out, "\n")
  end
end

function M.generate(opts)
  opts = opts or {}
  local today = opts.today or date.today()
  local range_start, range_end

  if opts.current_week then
    range_start, range_end = date.current_week_so_far(today)
  else
    range_start, range_end = date.previous_week_range(today)
  end

  local path = store.weekly_path(range_start)
  if store.file_exists(path) and not opts.force then
    return path, false
  end

  local latest, completed = latest_occurrences(range_start, range_end)
  local open_tasks = {}
  for task_id, task in pairs(latest) do
    if not task.done then
      open_tasks[task_id] = task
    end
  end

  local prompt = build_prompt(range_start, range_end, completed, open_tasks)
  local ai_summary = ""
  local payload = vim.json.encode({
    model = config.get().summary_model,
    messages = {
      {
        role = "system",
        content = "You summarize personal task journals. Be concise, concrete, and avoid filler.",
      },
      {
        role = "user",
        content = prompt,
      },
    },
  })

  local result = vim.system({
    "curl",
    "-sS",
    "-X",
    "POST",
    config.get().summary_url,
    "-H",
    "Content-Type: application/json",
    "-d",
    payload,
  }, { text = true, timeout = config.get().summary_timeout_ms }):wait()

  if result.code == 0 then
    local ok, decoded = pcall(vim.json.decode, result.stdout)
    if ok then
      ai_summary = vim.trim(extract_content(decoded) or "")
    end
  end

  store.save_weekly(path, render_summary(range_start, range_end, ai_summary, completed, open_tasks))
  return path, true
end

return M
