local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "gofumpt" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		python = { "black" },
		c = { "clang-format" },
		cpp = { "clang-format" },
	},
	format_on_save = false,
})

vim.keymap.set({ "n", "v" }, "<leader>mp", function()
	conform.format({
		lsp_fallback = true,
		async = false,
		timeout_ms = 1000,
	})
end, { desc = "Format file or range (in visual mode)" })
