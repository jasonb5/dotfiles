return {
    {
        'saghen/blink.cmp',
        build = 'cargo +nightly build --release',
        event = 'InsertEnter',
        opts = {
            keymap = {
                ['<CR>'] = { 'accept', 'fallback' },
                ['<C-\\>'] = { 'hide', 'fallback' },
                ['<C-n>'] = { 'select_next', 'show' },
                ['<Tab>'] = { 'select_next', 'fallback' },
                ['<C-p>'] = { 'select_prev' },
                ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
                ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
            },
        },
        keys = {
            { '<leader>bp', '<cmd>BufferLinePick<cr>', desc = 'Select buffer to open' },
            { '<leader>bc', '<cmd>BufferLinePickClose<cr>', desc = 'Select buffer to close' },
            { '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', desc = 'Close others' },
        },
    },
}
