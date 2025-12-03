vim.api.nvim_create_autocmd('FileType', {
    pattern = '*',
    callback = function()
        vim.treesitter.start()
        vim.bo.indentexpr = 'v:lua.require("nvim-treesittter").indentexpr()'
    end,
})
