return {
    {
        'stevearc/conform.nvim',
        event = 'BufWritePre',
        opts = {
            formatters_by_ft = {
                lua = { 'stylua' },
                python = { 'black' },
                rust = { 'rustfmt', lsp_format = 'fallback' },
            },
        },
    },
}
