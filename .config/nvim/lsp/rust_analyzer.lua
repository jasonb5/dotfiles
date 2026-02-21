---@type vim.lsp.Config
return {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
    settings = {
        ["rust-analyzer"] = {
            -- Additional rust-analyzer settings can go here
        },
    },
}

