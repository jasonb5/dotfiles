require("config.options")
require("config.keymaps")

vim.pack.add({
  { src = "https://github.com/rose-pine/neovim" },
  { src = "https://github.com/akinsho/bufferline.nvim" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
})

local plugin_dir = vim.fn.stdpath("config") .. "/lua/config/plugins"

for _, file in ipairs(vim.fn.readdir(plugin_dir)) do
  if file:match("%.lua$") then
    local module = file:gsub("%.lua$", "")
      require("config.plugins." .. module)
    end
end
