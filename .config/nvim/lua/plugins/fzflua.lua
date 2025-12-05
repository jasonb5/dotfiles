return {
    {
        'ibhagwan/fzf-lua',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        keys = {
            { '<leader>fb', '<cmd>FzfLua blines<cr>', desc = 'Search current buffer', mode = { 'n', 'x' } },
            { '<leader>fB', '<cmd>FzfLua buffers<cr>', desc = 'Search buffers' },
            { '<leader>fd', '<cmd>FzfLua lsp_document_diagnostics<cr>', desc = 'Search diagnostics' },
            { '<leader>ff', '<cmd>FzfLua files<cr>', desc = 'Find files' },
            { '<leader>fg', '<cmd>FzfLua live_grep<cr>', desc = 'Grep files' },
            { '<leader>fh', '<cmd>FzfLua help_tags<cr>', desc = 'Search help' },
            { '<leader>fr', '<cmd>FzfLua oldfiles<cr>', desc = 'Recently opened files' },
            { 'z=', '<cmd>FzfLua spell_suggest<cr>', desc = 'Spelling suggestions' },
        },
    },
}
