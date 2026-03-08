return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = {
			"Kaiser-Yang/blink-cmp-avante",
      {
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        build = "make install_jsregexp",
        dependencies = {
          "rafamadriz/friendly-snippets",
        },
        config = function()
          require("luasnip").setup({})

          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
		},
		opts = {
			keymap = {
				preset = "super-tab",
			},
      snippets = { preset = "luasnip" },
			sources = {
				default = { "lsp", "avante", "path", "snippets", "buffer" },
				providers = {
					avante = {
						module = "blink-cmp-avante",
						name = "Avante",
						opts = {},
					},
					avante_commands = {
						name = "avante_commands",
						module = "blink.compat.source",
						score_offset = 90,
						opts = {},
					},
					avante_files = {
						name = "avante_files",
						module = "blink.compat.source",
						score_offset = 100,
						opts = {},
					},
					avante_mentions = {
						name = "avante_mentions",
						module = "blink.compat.source",
						score_offset = 1000,
						opts = {},
					},
					avante_shortcuts = {
						name = "avante_shortcuts",
						module = "blink.compat.source",
						score_offset = 1000,
						opts = {},
					},
				},
			},
			completion = {
				documentation = {
					auto_show = true,
				},
			},
		},
	},
}
