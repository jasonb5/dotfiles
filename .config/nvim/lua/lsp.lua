local function on_attach(client, bufnr)
    if client:supports_method 'textDocument/references' then
        vim.keymap.set('n', '<leader>fr', '<cmd>FzfLua lsp_references<cr>')
    end

    if client:supports_method 'textDocument/definition' then
        vim.keymap.set('n', '<leader>fd', '<cmd>FzfLua lsp_definitions<cr>')
    end

    if client:supports_method 'textDocument/implementation' then
        vim.keymap.set('n', '<leader>fi', '<cmd>FzfLua lsp_implementations<cr>')
    end

    if client:supports_method 'textDocument/documentSymbol' then
        vim.keymap.set('n', '<leader>fs', '<cmd>FzfLua lsp_document_symbols<cr>')
    end

    if client:supports_method 'textDocument/codeAction' then
        vim.keymap.set('n', '<leader>ca', '<cmd>FzfLua lsp_code_actions<cr>')
    end

    if client:supports_method 'textDocument/signatureHelp' then
        vim.keymap.set('i', '<C-k>', function()
            vim.lsp.buf.signature_help()
        end)
    end
end

vim.diagnostic.config {
    virtual_text = {
        prefix = '',
        spacing = 2,
    },
    float = {
        source = 'if_many',
    },
    signs = false,
}

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local buf = args.buf

        on_attach(client, buf)
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
