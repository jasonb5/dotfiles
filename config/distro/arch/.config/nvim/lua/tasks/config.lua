local M = {}

local defaults = {
  root = "~/Documents/tasks",
  db_path = "~/.local/state/tasks/tasks.db",
  summary_url = "https://llama-swap.c.angrydonkey.io/v1/chat/completions",
  summary_model = "qwen3.5-4B",
  summary_timeout_ms = 30000,
}

M.values = vim.deepcopy(defaults)

function M.setup(opts)
  M.values = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  M.values.root = vim.fn.expand(M.values.root)
  M.values.db_path = vim.fn.expand(M.values.db_path)
  return M.values
end

function M.get()
  return M.values
end

return M
