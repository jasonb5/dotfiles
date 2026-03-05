return {
	{
		"olimorris/codecompanion.nvim",
		cmd = {
			"CodeCompanion",
			"CodeCompanionChat",
			"CodeCompanionAction",
			"CodeCompanionCmd",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"github/copilot.vim",
		},
		keys = {
			{ "<leader>tc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanion chat" },
			{ "<leader>as", "<cmd>CodeCompanionChat Add<cr>", desc = "Add to CodeCompanion chat", mode = "x" },
			{ "<leader>cca", "<cmd>CodeCompanionAction<cr>", desc = "CodeCompanion action" },
		},
		opts = {
			rules = {
				opts = {
					chat = {
						autoload = { "default" },
					},
				},
			},
			adapters = {
				acp = {
          claude_code = function()
            return require("codecompanion.adapters").extend("claude_code", {
              env = {
                CLAUDE_CODE_OAUTH_TOKEN = "cmd:bw get password anthropic.oauth_token",
              },
            })
          end,
				},
				http = {
					anthropic = function()
						return require("codecompanion.adapters").extend("anthropic", {
							env = {
								api_key = "cmd:bw get password anthropic.api_key",
							},
						})
					end,
					gemini = function()
						return require("codecompanion.adapters").extend("gemini", {
							env = {
								api_key = "cmd:bw get password gemini.api_key",
							},
						})
					end,
					mistral = function()
						return require("codecompanion.adapters").extend("mistral", {
							env = {
								api_key = "cmd:bw get password mistral.api_key",
							},
						})
					end,
				},
			},
			extensions = {
				mcphub = {
					callback = "mcphub.extensions.codecompanion",
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
		config = function(_, opts)
			local cwd = vim.fn.getcwd()
			local is_work_dir = cwd:lower():find("work", 1, true) ~= nil

			local default = {
				chat = {
					adapter = "claude_code",
          model = "claude-sonnet-4-6",
				},
				inline = {
					adapter = "claude_code",
          model = "claude-haiku-4-5",
				},
				cmd = {
					adapter = "claude_code",
          model = "claude-haiku-4-5",
				},
				background = {
					adapter = "claude_code",
          model = "claude-haiku-4-5",
				},
			}

			local work = {
				chat = {
					adapter = "copilot",
					model = "gpt-5-mini",
				},
				inline = {
					adapter = "copilot",
					model = "gpt-5-mini",
				},
				cmd = {
					adapter = "copilot",
					model = "gpt-5-mini",
				},
				background = {
					adapter = "copilot",
					model = "gpt-5-mini",
				},
			}

			opts.interactions = is_work_dir and work or default

			require("codecompanion").setup(opts)
		end,
	},
}
