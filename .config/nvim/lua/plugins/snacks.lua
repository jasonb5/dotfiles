return {
	{
		"folke/snacks.nvim",
		opts = {
			gh = {},
			indent = {},
      terminal = {},
		},
		keys = {
			{
				"<leader>gi",
				function()
					Snacks.picker.gh_issue()
				end,
				"GitHub Issues",
			},
			{
				"<leader>gp",
				function()
					Snacks.picker.gh_pr()
				end,
				"Github Pull Request",
			},
      {
        "<leader>t",
        function()
          Snacks.terminal()
        end,
        "Terminal"
      },
		},
	},
}
