local servers = {
    pyright = {},
    ruff = {},
}

return {
    {
        'kdheepak/lazygit.nvim',
        lazy = true,
        cmd = {
            'LazyGit',
            'LazyGitConfig',
            'LazyGitCurrentFile',
            'LazyGitFilter',
            'LazyGitFilterCurrentFile',
        },
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        keys = {
            { "<leader>lg", "<cmd>LazyGit<CR>", desc = "opens lazygit" },
        },
    },
    {
        'neomvim/nvim-lspconfig',
        dependencies = {
            { 'mason-org/mason.nvim', opts = {} },
            { 'mason-org/mason-lspconfig.nvim', opts = { ensure_installed = vim.tbl_keys(servers) } },
        },
    },
}
