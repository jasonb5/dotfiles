local servers = {
    pyright = {},
    ruff = {},
}

return {
    {
        'neomvim/nvim-lspconfig',
        dependencies = {
            { 'mason-org/mason.nvim', opts = {} },
            { 'mason-org/mason-lspconfig.nvim', opts = { ensure_installed = vim.tbl_keys(servers) } },
        },
    },
}
