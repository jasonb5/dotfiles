vim.diagnostic.config {}

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local buf = args.buf
    end,
})

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
    once = true,
    callback = function()
        vim.lsp.config('*', { capabilities = require'blink.cmp'.get_lsp_capabilities(nil, true) })

        local servers = vim.iter(vim.api.nvim_get_runtime_file('lsp/*.lua', true))
        :map(function(file)
            return vim.fn.fnamemodify(file, ':t:r')
        end)
        :totable()
        vim.lsp.enable(servers)
    end,
})
