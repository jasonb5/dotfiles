return {
	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = {
			"Kaiser-Yang/blink-cmp-avante",
		},
		opts = {
			keymap = {
				preset = "super-tab",
			},
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
