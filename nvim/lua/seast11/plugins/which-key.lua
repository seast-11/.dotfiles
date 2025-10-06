return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		local wk = require("which-key")
		wk.setup({
			layout = {
				align = "center",
			},
			win = {
				border = "bold",
				padding = { 1, 1 }, -- extra window padding [top/bottom, right/left]
				no_overlap = true,
			},
      preset = "helix",
			wk.add({
				{ "<leader>g", group = "LSP" },
				{ "<leader>f", group = "The Telescopes" },
				{ "<leader>s", group = "Sessions" },
				{ "<leader>e", group = "File Tree" },
				{ "<leader>l", group = "LazyGit" },
				{ "<leader>m", group = "Format & Lint" },
				{ "<leader>b", group = "Buffer" },
				{ "<leader>d", group = "DAP" },
				{ "<leader>t", group = "Tabs" },
				{ "<leader>s", group = "Splits" },
				{ "<leader>c", group = "BOB ROSS!" },
			}),
		})
	end,
}
