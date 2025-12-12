return {
    {
        'ibhagwan/fzf-lua',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        keys = {
            { '<leader>fb', '<cmd>FzfLua lgrep_curbuf<cr>', desc = 'Search current buffer' },
            { '<leader>fB', '<cmd>FzfLua buffers<cr>', desc = 'Search buffers' },
            { '<leader>fd', '<cmd>FzfLua lsp_document_diagnostics<cr>', desc = 'Document diagnostics' },
            { '<leader>fg', '<cmd>FzfLua live_grep<cr>', desc = 'Grep' },
            { '<leader>fh', '<cmd>FzfLua help_tags<cr>', desc = 'Help' },
        }
    },
}
