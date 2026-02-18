return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },
				go = { "gofumpt" },
        python = { "ruff_format" }, 
				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },
        yaml = { "prettier" },
        yml = { "prettier" },
        c = { "clang_format" },
        cpp = { "clang_format" },
			},
      format_on_save = false
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
