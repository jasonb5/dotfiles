local tools_root = vim.env.DOTFILES_ROOT or vim.fn.fnamemodify(vim.fn.stdpath("config"), ":p:h:h:h:h:h")
local tools_bin = tools_root .. "/tools/bin"

local conform = require("conform")

conform.setup({
  formatters = {
    rustfmt = {
      command = tools_bin .. "/rustfmt",
    },
    ruff_format = {
      command = tools_bin .. "/ruff",
      args = { "format" },
    },
    prettier = {
      command = tools_bin .. "/prettier",
    },
  },
  formatters_by_ft = {
    rust = { "rustfmt" },
    python = { "ruff_format" },
    css = { "prettier" },
    graphql = { "prettier" },
    html = { "prettier" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    markdown = { "prettier" },
    scss = { "prettier" },
    yaml = { "prettier" },
  },
  format_on_save = function()
    return {
      lsp_format = "fallback",
      timeout_ms = 1000,
    }
  end,
})

vim.keymap.set("n", "<leader>f", function()
  conform.format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

vim.keymap.set("n", "<leader>lc", "<cmd>Clippy<cr>", { desc = "Run clippy" })

vim.api.nvim_create_user_command("Clippy", function()
  local root = vim.fs.root(0, { "Cargo.toml" })
  if not root then
    vim.notify("No Cargo.toml found for clippy", vim.log.levels.WARN)
    return
  end

  local command = { tools_bin .. "/cargo-clippy", "--workspace", "--all-targets", "--all-features", "--message-format=json" }

  vim.system(command, { cwd = root, text = true }, function(result)
    local items = {}

    for line in vim.gsplit(result.stdout or "", "\n", { plain = true, trimempty = true }) do
      local ok, message = pcall(vim.json.decode, line)
      if ok and message.reason == "compiler-message" then
        local span = message.message.spans and message.message.spans[1]
        if span and span.file_name and span.line_start then
          table.insert(items, {
            filename = span.file_name,
            lnum = span.line_start,
            col = span.column_start or 1,
            text = message.message.message,
            type = message.message.level == "warning" and "W" or "E",
          })
        end
      end
    end

    vim.schedule(function()
      vim.fn.setqflist({}, "r", {
        title = "cargo clippy",
        items = items,
      })

      if #items > 0 then
        vim.cmd("copen")
      end
    end)
  end)
end, {})
