local null_ls = require("null-ls")

local sources = {
	null_ls.builtins.formatting.stylua.with({
		filetypes = { "lua" },
	}),
	null_ls.builtins.formatting.black.with({ extra_args = { "--fast" } }),
}

null_ls.setup({ sources = sources })
