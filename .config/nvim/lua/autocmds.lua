-- Keep split sizes balanced when the editor window is resized
vim.api.nvim_create_autocmd('VimResized', {
  pattern = '*',
  command = 'wincmd =',
})
