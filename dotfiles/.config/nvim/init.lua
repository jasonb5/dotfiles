local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
            { out, 'WarningMsg' },
            { '\nPress any key to exit...' },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)


local g = vim.g
local opt = vim.opt
local key = vim.keymap.set

g.mapleader = ' '
g.maplocalleader = ' '

opt.number = true
opt.relativenumber = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

opt.incsearch = true
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.splitright = true
opt.splitbelow = true

opt.mouse = 'a'
opt.clipboard = 'unnamedplus'

opt.undofile = true
opt.swapfile = false

opt.encoding = 'utf-8'

opt.signcolumn = 'yes'

key('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear highlighting' })

key('n', '<leader>\\', '<cmd>vsplit<cr>', { desc = 'Vertical split' })
key('n', '<leader>-', '<cmd>split<cr>', { desc = 'Horizontal split' })

key('n', '<C-h>', '<C-w>h', { desc = 'Move to left split' })
key('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom split' })
key('n', '<C-k>', '<C-w>k', { desc = 'Move to top split' })
key('n', '<C-l>', '<C-w>l', { desc = 'Move to right split' })

key('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase split height' })
key('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease split height' })
key('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease split width' })
key('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase split width' })

key('n', '<leader>bn', '<cmd>bnext<cr>', { desc = 'Move to next buffer' })
key('n', '<leader>bp', '<cmd>bprevious<cr>', { desc = 'Move to previous buffer' })
key('n', '<leader>bd', function()
    Snacks.bufdelete.delete()
end, { desc = 'Delete buffer' })
key('n', '<leader>od', function()
    Snacks.bufdelete.other()
end, { desc = 'Delete other buffers' })

key('n', '<leader>fn', '<cmd>enew<cr>', { desc = 'New file' })

key('n', '<leader>w', '<cmd>w<cr>', { desc = 'Write buffer' })
key('n', '<leader>q', '<cmd>q<cr>', { desc = 'Quit ' })

require('lazy').setup({
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        config = function()
            vim.cmd('colorscheme rose-pine')
        end,
    },
    {
        'akinsho/bufferline.nvim',
        event = 'VeryLazy',
        opts = {},
    },
    {
        'nvim-lualine/lualine.nvim',
        event = 'VeryLazy',
        opts = {},
    },
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = false,
        branch = 'main',
        build = ':TSUpdate',
        opts = {},
        config = function(_, opts)
            require('nvim-treesitter').install({
                'bash',
                'json',
                'lua',
                'markdown',
                'markdown_inline',
                'python',
                'query',
                'regex',
                'xml',
                'yaml',
            }, { summary = true })

            vim.api.nvim_create_autocmd('FileType', {
                pattern = { 'lua' },
                callback = function(ev)
                    vim.treesitter.start()
                end,
            })

            vim.bo.indentexpr = 'v:lua.require"nvim-treesitter".indextexpr()'
        end,
    },
    {
        'neovim/nvim-lspconfig',
        event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' },
        dependencies = {
            { 'mason-org/mason.nvim', opts = {} },
            'mason-org/mason-lspconfig.nvim',
            'saghen/blink.cmp',
        },
        opts = {
            servers = {
                lua_ls = {
                    Lua = {
                        runtime = {
                            version = 'LuaJIT',
                        },
                        diagnostics = {
                            globals = { 'vim' },
                        },
                        workspace = {
                            library = {
                                vim.env.VIMRUNTIME,
                                vim.fn.stdpath('data') .. '/lazy/',
                            },
                        },
                    },
                },
                pyright = {},
            },
        },
        config = function(_, opts)
            local registry = require('mason-registry')
            local specs = registry.get_all_package_specs()
            local Package = require('mason-core.package')
            local lspconfig_to_package = {}

            -- build registry of lspconfig to package
            for _, package_spec in ipairs(specs) do
                local lspconfig = vim.tbl_get(package_spec, 'neovim', 'lspconfig')

                if lspconfig then
                    lspconfig_to_package[lspconfig] = package_spec.name
                end
            end

            for pkgname, _ in pairs(opts.servers) do
                local name, version = Package.Parse(pkgname)
                -- package name from lspconfig
                local package_name = lspconfig_to_package[name]
                local ok, package = pcall(registry.get_package, package_name)

                if ok and not package:is_installed() and not package:is_installing() then
                    package:install({ version = version}, function(success, err)
                        if success then
                            print('Installed ', name)
                        else
                            print('Failed to install ', name, ' error ', err)
                        end
                    end)
                end
            end

            local lspconfig = require('lspconfig')

            for server, config in pairs(opts.servers) do
                config.capabilities = require('blink.cmp').get_lsp_capabilities()

                lspconfig[server].setup({ settings = config })
            end
        end,
        keys = {
            { '<leader>ca', function() vim.lsp.buf.code_action() end, { desc = 'Code action' } },
            { 'K', function() vim.lsp.buf.hover() end, { 'Hover information' } },
        },
    },
    {
        'saghen/blink.cmp',
        event = { 'InsertEnter', 'CmdlineEnter' },
        build = 'cargo build --release',
        opts = {
            completion = {
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 500,
                    treesitter_highlighting = false
                },
                ghost_text = {
                    enabled = true
                },
            },
            signature = {
                enabled = true,
            },
            keymap = {
                preset = 'enter',
                ['<C-y>'] = { 'select_and_accept' },
            },
        },
    },
    {
        'folke/snacks.nvim',
        priority = 1000,
        lazy = false,
        opts = {
            bigfile = {},
            dim = {},
            explorer = {},
            indent = {},
            input = {},
            lazygit = {},
            picker = {},
            quickfile = {},
            scroll = {},
            terminal = {},
        },
        config = function(_, opts)
            require('snacks').setup(opts)
        end,
        keys = {
            { '<leader>e', function() Snacks.explorer.open() end, { desc = 'Opens explorer' } },
            { '<leader>lg', function() Snacks.lazygit.open() end, { desc = 'Opens lazygit' } },
            { '<leader>fb', function() Snacks.picker.buffers() end, { desc = 'Find buffer' } },
            { '<leader>ff', function() Snacks.picker.files() end, { desc = 'Find files' } },
            { '<leader>fg', function() Snacks.picker.git_files() end, { desc = 'Find git files' } },
            { '<leader>fr', function() Snacks.picker.recent() end, { desc = 'Find recent' } },
            { '<leader>sb', function() Snacks.picker.lines() end, { desc = 'Search buffer' } },
            { '<leader>sB', function() Snacks.picker.grep_buffers() end, { desc = 'Search all buffes' } },
            { '<leader>sg', function() Snacks.picker.grep() end, { desc = 'Search all files' } },
            { '<leader>sd', function() Snacks.picker.diagnostics() end, { desc = 'Search diagnostics' } },
            { '<leader>sh', function() Snacks.picker.help() end, { desc = 'Search help' } },
            { '<leader>si', function() Snacks.picker.icons() end, { desc = 'Search icons' } },
            { '<leader>sq', function() Snacks.picker.qflist() end, { desc = 'Search quickfix list' } },
            { 'gd', function() Snacks.picker.lsp_definitions() end, { desc = 'Goto definition' } },
            { 'gD', function() Snacks.picker.lsp_declarations() end, { desc = 'Goto declaration' } },
            { 'gr', function() Snacks.picker.lsp_references() end, { desc = 'Goto reference' } },
            { 'gI', function() Snacks.picker.lsp_implementations() end, { desc = 'Goto implementation' } },
            { 'gy', function() Snacks.picker.lsp_type_definitions() end, { desc = 'Goto type definition' } },
            { '<leader>ss', function() Snacks.picker.lsp_symbols() end, { desc = 'Search symbols' } },
            { '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, { desc = 'Search workspace symbols' } },
        },
    },
    {
        'nvim-mini/mini.pairs',
        event = 'VeryLazy',
        opts = {},
    },
    {
        'lewis6991/gitsigns.nvim',
        opts = {}
    },
    {
        'danymat/neogen',
        opts = {},
        keys = {
            { '<leader>cn', function() require('neogen').generate() end, desc = 'Generation Annotations' },
        },
    },
})
