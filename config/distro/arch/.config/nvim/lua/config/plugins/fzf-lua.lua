local fzf = require("fzf-lua")
fzf.setup({})

vim.keymap.set("n", "<leader>ff", function()
  fzf.files()
end, { desc = "Find files" })
