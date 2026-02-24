vim.diagnostic.config {}

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local buf = args.buf

        if client:supports_method 'textDocument/references' then
            vim.keymap.set('n', '<leader>fr', function()
                require'fzf-lua'.lsp_references()
            end)
        end

        if client:supports_method 'textDocument/definition' then
            vim.keymap.set('n', '<leader>fd', function()
                require'fzf-lua'.lsp_definitions()
            end)
        end

        if client:supports_method 'textDocument/implementation' then
            vim.keymap.set('n', '<leader>fi', function()
                require'fzf-lua'.lsp_implementations()
            end)
        end

        if client:supports_method 'textDocument/documentSymbol' then
            vim.keymap.set('n', '<leader>fs', function()
                require'fzf-lua'.lsp_document_symbols()
            end)
        end

        if client:supports_method 'textDocument/codeAction' then
            vim.keymap.set('n', '<leader>ca', function()
                require'fzf-lua'.lsp_code_actions()
            end)
        end

        if client:supports_method 'textDocument/signatureHelp' then
            vim.keymap.set({'i', 'n', 'x'}, '<leader>k', function()
                vim.lsp.buf.signature_help()
            end)
        end
    end,
})

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
    once = true,
    callback = function()
        vim.lsp.config('*', { capabilities = require'blink.cmp'.get_lsp_capabilities(nil, true) })

        vim.diagnostic.config({
            virtual_text = true
        })

        local servers = vim.iter(vim.api.nvim_get_runtime_file('lsp/*.lua', true))
        :map(function(file)
            return vim.fn.fnamemodify(file, ':t:r')
        end)
        :totable()
        vim.lsp.enable(servers)
    end,
})
