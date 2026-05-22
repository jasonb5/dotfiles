vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local keymap = vim.keymap

keymap.set("n", "<leader>sv", "<C-w>v")
keymap.set("n", "<leader>sh", "<C-w>s")
keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { silent = true, desc = "Previous buffer" })
keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { silent = true, desc = "Next buffer" })
keymap.set("n", "<leader>to", "<cmd>TaskOpenToday<cr>", { silent = true, desc = "Open today's tasks" })
keymap.set("n", "<leader>ta", "<cmd>TaskAdd<cr>", { silent = true, desc = "Add task" })
keymap.set("n", "<leader>tx", "<cmd>TaskToggle<cr>", { silent = true, desc = "Toggle task" })
