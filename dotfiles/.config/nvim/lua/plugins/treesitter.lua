return {
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        branch = 'main',
        build = ':TSUpdate',
        config = function(self, opts)
            require'nvim-treesitter'.setup {}
            require'nvim-treesitter'.install(opts.parsers)
        end,
        opts = {
            parsers = {
                'bash',
                'gitcommit',
                'json',
                'jsonc',
                'lua',
                'markdown',
                'markdown_inline',
                'python',
                'regex',
                'toml',
                'vim',
                'vimdoc',
                'yaml',
            },
        },
    },
}
