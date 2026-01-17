return {
    {
        'olimorris/codecompanion.nvim',
        cmd = 'CodeCompanion',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'zbirenbaum/copilot.lua',
        },
        keys = {
            { '<leader>cc', '<cmd>CodeCompanionChat Toggle<cr>', desc = 'Toggle CodeCompanion chat' },
            { '<leader>ca', '<cmd>CodeCompanionChat Add<cr>', desc = 'Add to CodeCompanion chat', mode = 'x' },
        },
        opts = {
            extensions = {
                mcphub = {
                    callback = 'mcphub.extensions.codecompanion',
                    opts = {
                        make_tools = true,
                        show_server_tools_in_chat = true,
                        add_mcp_prefix_to_tool_names = false,
                        show_result_in_chat = true,
                        format_tool = nil,
                        make_vars = true,
                        make_slash_commands = true,
                    },
                },
            },
        },
    },
}
