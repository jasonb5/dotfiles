return {
  "nickjvandyke/opencode.nvim",
  event = "VeryLazy",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    opencode = {
      cmd = { "nopencode", "--port" },
      auto_detect = true,
    },
    server = {
      port = 4096,
    },
    events = {
      reload = true,
    },
  },
  keys = {
    { "<leader>oo", function() require("opencode").toggle() end, desc = "Toggle opencode" },
    { "<leader>oa", function() require("opencode").ask() end, desc = "Ask opencode", mode = { "n", "x" } },
    { "<leader>os", function() require("opencode").select() end, desc = "Ask opencode selection", mode = { "n", "x" } },
    { "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, desc = "Ask opencode with @this", mode = { "n", "x" } },
    { "go", function() return require("opencode").operator("@this ") end, desc = "Add range to opencode", expr = true, mode = { "n", "x" } },
    { "gx", function() return require("opencode").operator("@this ") .. "_" end, desc = "Add line to opencode", expr = true, mode = { "n", "x" } },
    { "<S-C-u>", function() require("opencode").command("session.half.page.up") end, desc = "Scroll opencode up" },
    { "<S-C-d>", function() require("opencode").command("session.half.page.down") end, desc = "Scroll opencode down" },
  },
  config = function()
    vim.o.autoread = true
  end,
}
