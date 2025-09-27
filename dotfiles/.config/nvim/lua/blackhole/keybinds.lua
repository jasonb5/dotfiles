vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "vertical split" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "horizontal split" })

vim.keymap.set("n", "<leader>sc", ":close<CR>", { desc = "close split" })
vim.keymap.set("n", "<leader>scl", ":only<CR>", { desc = "close all splits except current" })
vim.keymap.set("n", "<leader>st", "<C-w>T", { desc = "move split to new tab" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "equalize split sizes" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "move to botom split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "move to top split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "move to right split" })

vim.keymap.set("n", "<S-k>", ":resize +2<CR>", { desc = "increase split height" })
vim.keymap.set("n", "<S-j>", ":resize -2<CR>", { desc = "decrease split height" })
vim.keymap.set("n", "<S-h>", ":vertical resize -2<CR>", { desc = "decrease split width" })
vim.keymap.set("n", "<S-l>", ":vertical resize +2<CR>", { desc = "increase split width" })

vim.keymap.set("n", "<leader>te", ":tabedit<CR>", { desc = "new tab" })
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { desc = "close tab" })
vim.keymap.set("n", "<leader>to", ":tabonly<CR>", { desc = "close all except current" })
vim.keymap.set("n", "<leader>tn", ":tabnext<CR>", { desc = "tab next" })
vim.keymap.set("n", "<leader>tp", ":tabprevious<CR>", { desc = "tab previous" })
for i = 1, 9 do
    vim.keymap.set("n", string.format("<leader>t%d", i), string.format(":%dtabnext<CR>", i), { desc = string.format("go to tab %d", i) })
end

vim.keymap.set("v", "<", "<gv", { desc = "indent left and stay in visual mode" })
vim.keymap.set("v", ">", ">gv", { desc = "indent right and stay in visual mode" })

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "move selected line down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "move selected line up" })

vim.keymap.set("n", "<leader>d", "yyP", { desc = "duplicate line" })

vim.keymap.set("n", "<leader>hc", ":nohlsearch<CR>", { desc = "clear search highlight" })

vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "save file" })
