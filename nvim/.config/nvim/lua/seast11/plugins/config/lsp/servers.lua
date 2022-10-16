-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
	local opts = { noremap = true, silent = true }

	-- workspace mappings
	vim.api.nvim_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
	vim.api.nvim_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
	vim.api.nvim_set_keymap(
		"n",
		"<space>wl",
		"<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
		opts
	)

	-- actions and diagnostics mappings
	vim.api.nvim_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
	vim.api.nvim_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
	vim.api.nvim_set_keymap("n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
	vim.api.nvim_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.format{ async = true }<CR>", opts)
	vim.api.nvim_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	vim.api.nvim_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	vim.api.nvim_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)

	-- telescope lsp mappings
	vim.api.nvim_set_keymap("n", "<space>fu", "<cmd>Telescope lsp_references<CR>", opts)
	vim.api.nvim_set_keymap("n", "<space>gd", "<cmd>Telescope lsp_definitions<CR>", opts)
	vim.api.nvim_set_keymap("n", "<space>dD", "<cmd>Telescope diagnostics<CR>", opts)
	vim.api.nvim_set_keymap("n", "<space>dd", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
	vim.api.nvim_set_keymap("n", "<space>ca", "<cmd>Telescope lsp_code_actions<CR>", opts)
	vim.api.nvim_set_keymap("n", "<space>cd", "<cmd>%Telescope lsp_range_code_actions<CR>", opts)

	-- Set autocommands conditional on server_capabilities
	-- if client.resolved_capabilities.document_highlight then
	-- 	vim.api.nvim_exec(
	-- 		[[
	--       augroup lsp_document_highlight
	--         autocmd! * <buffer>
	--         autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
	--         autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
	--       augroup END
	--     ]],
	-- 		false
	-- 	)
	-- end
end

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
local nvim_lsp = require("lspconfig")

local function on_cwd()
	return vim.loop.cwd()
end

-- OmniSharp specifics
local pid = vim.fn.getpid()
local omnisharp_bin
if vim.loop.os_uname().sysname == "Linux" then
	omnisharp_bin = vim.fn.exepath("omnisharp")
else
	omnisharp_bin = "C:/Tools/OmniSharp/OmniSharp.exe"
end

nvim_lsp.omnisharp.setup({
	cmd = { omnisharp_bin, "--languageserver", "--hostPID", tostring(pid) },
	capabilities = capabilities,
	on_attach = on_attach,
	root_dir = on_cwd,
})

-- Sumneko Lua specifics
local sumneko_binary_path
local sumneko_root_path
local sumneko_cmd = {}
if vim.loop.os_uname().sysname == "Linux" then
	sumneko_binary_path = vim.fn.exepath("lua-language-server")
	sumneko_root_path = vim.fn.fnamemodify(sumneko_binary_path, ":h:h:h")
	sumneko_cmd = { sumneko_binary_path, "-E", sumneko_root_path .. "/main.lua" }
else
	sumneko_binary_path = "C:/Tools/Sumneko_Lua/bin/lua-language-server.exe"
	sumneko_cmd = { sumneko_binary_path }
end

nvim_lsp.sumneko_lua.setup({
	cmd = sumneko_cmd,
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		Lua = {
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
			-- Do not send telemetry data containing a randomized but unique identifier
			telemetry = {
				enable = false,
			},
		},
	},
})

-- jsonls specifics
nvim_lsp.jsonls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
	-- Set the schema so that it can be completed in settings json file.
	settings = {
		json = {
			schemas = require("seast11.plugins.config.lsp.settings.jsonls").extended_schemas,
		},
		setup = {
			commands = {
				Format = {
					function()
						vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line("$"), 0 })
					end,
				},
			},
		},
	},
})

-- easy setups with no custom configurations
local servers = { "pyright", "gopls", "clangd", "dockerls", "yamlls", "tsserver" }

for _, lsp in ipairs(servers) do
	nvim_lsp[lsp].setup({
		capabilities = capabilities,
		on_attach = on_attach,
	})
end
