if vim.g.loaded_local_tasks_plugin == 1 then
  return
end

vim.g.loaded_local_tasks_plugin = 1

local tasks = require("tasks")

tasks.setup()

vim.api.nvim_create_user_command("TaskOpenToday", function()
  tasks.open_today()
end, {})

vim.api.nvim_create_user_command("TaskRecent", function()
  tasks.open_recent_picker()
end, {})

vim.api.nvim_create_user_command("TaskAdd", function()
  tasks.add_task()
end, {})

vim.api.nvim_create_user_command("TaskToggle", function()
  tasks.toggle_current_task()
end, {})

vim.api.nvim_create_user_command("TaskIndex", function()
  tasks.refresh_index()
end, {})

vim.api.nvim_create_user_command("TaskRegenerateToday", function()
  tasks.regenerate_today()
end, {})
