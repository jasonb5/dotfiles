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
            { '<leader>c',  '<cmd>CodeCompanionAction<cr>', desc = 'CodeCompanion action' },
        },
        opts = {
            interactions = {
                chat = {
                    adapter = "gemini_cli"
                },
                inline = {
                    adapter = {
                        name = "mistral",
                        model = "mistral-small-latest"
                    }
                },
            },
            adapters = {
                http = {
                    anthropic = function()
                        return require('codecompanion.adapters').extend('anthropic', {
                            env = {
                                api_key = "cmd:bw get password anthropic.api_key",
                            },
                        })
                    end,
                    gemini = function()
                        return require('codecompanion.adapters').extend('gemini',  {
                            env = {
                                api_key = "cmd:bw get password gemini.api_key",
                            },
                        })
                    end,
                    mistral = function()
                        return require('codecompanion.adapters').extend('mistral', {
                            env = {
                                api_key = "cmd:bw get password mistral.api_key",
                            },
                        })
                    end,
                    openai = function()
                        return require('codecompanion.adapters').extend('openai', {
                            env = {
                                api_key = "cmd:bw get password openai.api_key",
                            },
                        })
                    end,
                },
            },
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
