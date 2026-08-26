return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".git", "lua" },
	settings = {
		Lua = {
			runtime = { version = "Lua 5.4" },
			diagnostics = { enable = true },
			workspace = {
				checkThirdParty = false,
				library = { vim.fn.expand("~") },
			},
			format = {
				enable = false, -- handled by stylua
			},
		},
	},
}
