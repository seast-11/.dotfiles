local function highlight_symbol(event)
	local client = vim.lsp.get_client_by_id(event.data.client_id)
	if not client or not client.supports_method("textDocument/documentHighlight") then
		return
	end

	local bufnr = event.buf
	local group = vim.api.nvim_create_augroup("lsp_highlight" .. bufnr, { clear = true })

	vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
		buffer = bufnr,
		group = group,
		callback = vim.lsp.buf.document_highlight,
	})

	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		buffer = bufnr,
		group = group,
		callback = vim.lsp.buf.clear_references,
	})
end

local function setup_lsp_keymaps(event)
	local map = function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
	end

	local client = vim.lsp.get_client_by_id(event.data.client_id)

	Snacks.notify.info("LSP attached: " .. client.name, { timeout = 500 })

	-- Go-specific keymaps (gopls) 🚀
	if client and client.name == "gopls" then
		-- Organize imports
		map("<leader>go", function()
			vim.lsp.buf.code_action({
				filter = function(action)
					return action.kind and string.match(action.kind, "source.organizeImports")
				end,
				apply = true,
			})
		end, "GO - Organize Imports")

		-- Fill struct
		map("<leader>gf", function()
			vim.lsp.buf.code_action({
				filter = function(action)
					return action.kind and string.match(action.kind, "refactor.rewrite")
				end,
				apply = true,
			})
		end, "GO - Fill Struct")
	end
end

-- Main autocmd to set everything up when an LSP server attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Setup LSP keymaps and symbol highlighting",
	callback = function(event)
		highlight_symbol(event)
		setup_lsp_keymaps(event)
	end,
})

-- Autocmd to highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
