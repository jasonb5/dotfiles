return {
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        branch = 'main',
        build = ':TSUpdate',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
        },
        config = function()
            require('nvim-treesitter').setup{
                'lua',
            }

            vim.api.nvim_create_autocmd('FileType', {
                pattern= { 'lua' },
                callback = function() vim.treesitter.start() end,
            })

            vim.bo.indentexpr = 'v:lua.require("nvim-treesitter").indentexpr()'
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
    },
}
