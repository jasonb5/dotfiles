return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		branch = "main",
		build = ":TSUpdate",
		opts = {
			parsers = {
				"bash",
				"gitcommit",
				"jinja",
				"jinja_inline",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"regex",
				"rust",
				"toml",
				"vim",
				"vimdoc",
				"yaml",
			},
		},
		config = function(_, opts)
			require("nvim-treesitter").setup({})
			require("nvim-treesitter").install(opts.parsers)

			vim.api.nvim_create_autocmd("FileType", {
				pattern = opts.parsers,
				callback = function()
					vim.treesitter.start()
					vim.bo.indentexpr = 'v:lua.require("nvim-treesittter").indentexpr()'
				end,
			})
		end,
	},
}
