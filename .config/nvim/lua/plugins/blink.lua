return {
    {
        'saghen/blink.cmp',
        build = 'cargo +nightly build --release',
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
        completion = {
            list = {
                selection = { preselect = false, auto_insert = true },
                max_items = 10,
            },
            documentation = { auto_show = true },
            menu = {
                scrollbar = false,
            }
        },
        keys = {
            { '<leader>bp', '<cmd>BufferLinePick<cr>', desc = 'Select buffer to open' },
            { '<leader>bc', '<cmd>BufferLinePickClose<cr>', desc = 'Select buffer to close' },
            { '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', desc = 'Close others' },
        },
    },
}
