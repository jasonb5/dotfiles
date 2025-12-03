return {
    {
        'nvim-treesitter/nvim-treesitter',
        dependencies = {},
        version = false,
        build = ':TSUpdate',
        opts = {
            ensure_installed = {
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
            highlight = { enable = true },
            indent = { enable = true },
        },
    },
}
