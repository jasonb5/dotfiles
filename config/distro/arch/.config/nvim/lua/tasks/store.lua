local config = require("tasks.config")
local date = require("tasks.date")
local parser = require("tasks.parser")

local M = {}

local function ensure_dir(path)
  vim.fn.mkdir(path, "p")
end

local function read_file(path)
  local lines = vim.fn.readfile(path)
  return table.concat(lines, "\n")
end

local function write_file(path, text)
  ensure_dir(vim.fn.fnamemodify(path, ":h"))
  vim.fn.writefile(vim.split(text, "\n", { plain = true }), path)
end

function M.file_exists(path)
  return vim.fn.filereadable(path) == 1
end

function M.is_daily_path(path)
  local root = config.get().root
  return path:sub(1, #root) == root and path:match("/%d%d%d%d/%d%d%-%d%d%.md$") ~= nil
end

function M.date_for_path(path)
  local year, month, date_day = path:match("/(%d%d%d%d)/(%d%d)%-(%d%d)%.md$")
  if not year then
    return nil
  end

  return string.format("%s-%s-%s", year, month, date_day)
end

function M.daily_path(day)
  return date.daily_path(config.get().root, day)
end

function M.weekly_path(day)
  return date.weekly_path(config.get().root, day)
end

function M.load_daily(day)
  local path = M.daily_path(day)
  if not M.file_exists(path) then
    return parser.new_daily(day), path, false
  end

  return parser.parse_daily(read_file(path), day), path, true
end

function M.save_daily(doc)
  write_file(M.daily_path(doc.date), parser.render_daily(doc))
end

function M.ensure_daily(day)
  local doc, path, exists = M.load_daily(day)
  if not exists then
    M.save_daily(doc)
  end
  return doc, path, exists
end

function M.load_daily_path(path)
  local day = path:match("/(%d%d%d%d/%d%d%-%d%d)%.md$")
  if not day then
    return nil
  end

  local normalized = day:gsub("/", "-")
  return parser.parse_daily(read_file(path), normalized)
end

function M.list_daily_paths()
  local root = config.get().root
  local paths = vim.fn.globpath(root, "????/??-??.md", false, true)
  table.sort(paths)
  return paths
end

function M.find_previous_daily(day)
  local target = M.daily_path(day)
  local previous = nil

  for _, path in ipairs(M.list_daily_paths()) do
    if path < target then
      previous = path
    end
  end

  return previous
end

function M.save_weekly(path, text)
  write_file(path, text)
end

function M.read_weekly(path)
  if not M.file_exists(path) then
    return nil
  end
  return read_file(path)
end

function M.path_for_buffer(bufnr)
  return vim.api.nvim_buf_get_name(bufnr or 0)
end

return M
