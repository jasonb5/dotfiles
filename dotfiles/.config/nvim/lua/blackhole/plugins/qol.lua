return {
    {
        'folke/snacks.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            explorer = {},
            git = {},
            indent = {},
            lazygit = {},
            picker = {},
            quickfile = {},
            statuscolumn = {},
        },
        keys = {
            { '<leader>gb', function() Snacks.git.blame_line() end, desc = 'Get GIT blame for line' },
            { '<leader>lg', function() Snacks.lazygit() end, desc = 'Open lazygit' },
            { '<leader>e', function() Snacks.explorer() end, desc = 'File explorer' },
            { '<leader>fb', function() Snacks.picker.buffers() end, desc = 'Find buffers' },
            { '<leader>ff', function() Snacks.picker.files({ hidden = true }) end, desc = 'Find files' } ,
            { '<leader>fg', function() Snacks.picker.git_files() end, desc = 'Find git files' },
            { '<leader>gl', function() Snacks.picker.lines() end, desc = 'Grep lines' },
            { '<leader>gb', function() Snacks.picker.grep_buffers() end, desc = 'Grep buffers' },
            { '<leader>g', function() Snacks.picker.grep({ hidden = true }) end, desc = 'Grep' },
            { '<leader>ss', function() Snacks.picker.lsp_symbols() end, desc = 'LSP Symbols' },
        },
    },
}
