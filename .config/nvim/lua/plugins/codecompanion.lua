return {
    {
        'olimorris/codecompanion.nvim',
        cmd = 'CodeCompanion',
        dependencies = { 'nvim-lua/plenary.nvim' },
        keys = {
            { '<leader>at', '<cmd>CodeCompanionChat Toggle<cr>', desc = 'Toggle CodeCompanion chat' },
            { '<leader>aa', '<cmd>CodeCompanionChat Add<cr>', desc = 'Add to CodeCompanion chat', mode = 'x' },
        },
        opts = {},
    },
}
