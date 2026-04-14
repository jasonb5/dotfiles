vim.pack.add({ 'https://github.com/rose-pine/neovim' })

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true

require('rose-pine').setup({
  variant = 'moon',
})
vim.cmd('colorscheme rose-pine')
