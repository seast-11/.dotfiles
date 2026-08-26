vim.lsp.enable({
	"gopls",
  "golangci_lint_ls",
	"pyright",
	"bashls",
	"yamlls",
	"clangd",
	"lua_ls",
})

-- ===============================
-- LSP Notifications & Progress
-- ===============================

-- Track ongoing progress messages
local progress_messages = {}
local progress_counter = {}
local min_display = 250 -- ms per update
local dots = { ".", "..", "...", "" }

-- LSP errors, warnings, info
vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
	local client = vim.lsp.get_client_by_id(ctx.client_id)
	if not client then
		return
	end
	local msg = string.format("[%s] %s", client.name, result.message)

	if result.type == vim.lsp.protocol.MessageType.Error then
		Snacks.notify.error(msg)
	elseif result.type == vim.lsp.protocol.MessageType.Warning then
		Snacks.notify.warn(msg)
	else
		Snacks.notify.info(msg)
	end
end

-- LSP progress handler (smoothed, dot spinner)
vim.lsp.handlers["$/progress"] = function(_, result, ctx)
	local client = vim.lsp.get_client_by_id(ctx.client_id)
	if not client then
		return
	end
	local val = result.value
	local client_id = ctx.client_id

	progress_messages[client_id] = progress_messages[client_id] or { id = nil, ts = 0 }
	progress_counter[client_id] = progress_counter[client_id] or 0

	local now = vim.loop.now()
	local prev = progress_messages[client_id]

	if val.kind == "begin" then
		progress_counter[client_id] = 0
		progress_messages[client_id] = {
			id = Snacks.notify.info(string.format("[%s] %s...", client.name, val.title)),
			ts = now,
		}
	elseif val.kind == "report" then
		-- Only update if enough time has passed
		if now - prev.ts >= min_display then
			progress_counter[client_id] = progress_counter[client_id] + 1
			local dot = dots[(progress_counter[client_id] % #dots) + 1]
			progress_messages[client_id] = {
				id = Snacks.notify.info(
					string.format("[%s] %s: %s %s", client.name, val.title, val.message or "", dot),
					{ id = prev.id, replace = prev.id }
				),
				ts = now,
			}
		end
	elseif val.kind == "end" then
		progress_messages[client_id] = {
			id = Snacks.notify(
				string.format("[%s] %s ✓", client.name, " locked and loaded"),
				{ id = prev.id, replace = prev.id, timeout = 1500 }
			),
			ts = now,
		}
	end
end

-- Diagnostic configuration
vim.diagnostic.config({
	virtual_lines = false,
	virtual_text = false,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
		numhl = {
			[vim.diagnostic.severity.ERROR] = "ErrorMsg",
			[vim.diagnostic.severity.WARN] = "WarningMsg",
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		source = "always",
		border = "rounded",
	},
})

-- Namespace for current-line diagnostics
local ns = vim.api.nvim_create_namespace("CurrentLineDiagnostics")

-- Store which mode is active
local diag_state = { mode = nil } -- "text", "lines", or nil

-- Function to show diagnostics for current line only
local function show_line_diagnostics()
	vim.diagnostic.hide(ns) -- clear our namespace globally

	if not diag_state.mode then
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
	local diags = vim.diagnostic.get(bufnr, { lnum = lnum })

	if vim.tbl_isempty(diags) then
		return
	end

	local opts = {
		virtual_text = diag_state.mode == "text" and {
			prefix = "●",
			spacing = 2,
			source = "if_many",
		} or false,
		virtual_lines = diag_state.mode == "lines",
	}

	-- ✅ Correct API call (bufnr, namespace, diagnostics, opts)
	vim.diagnostic.show(ns, bufnr, diags, opts)
end

-- Update diagnostics on movement/hold
vim.api.nvim_create_autocmd({ "CursorHold", "CursorMoved" }, {
	callback = show_line_diagnostics,
})

-- Toggle functions
local function toggle_virtual_text()
	if diag_state.mode == "text" then
		diag_state.mode = nil
		vim.notify("Virtual text off")
	else
		diag_state.mode = "text"
		vim.notify("Virtual text (current line only)")
	end
	show_line_diagnostics()
end

local function toggle_virtual_lines()
	if diag_state.mode == "lines" then
		diag_state.mode = nil
		vim.notify("Virtual lines off")
	else
		diag_state.mode = "lines"
		vim.notify("Virtual lines (current line only)")
	end
	show_line_diagnostics()
end

-- Keymaps
vim.keymap.set("n", "<leader>dv", toggle_virtual_text, { desc = "DAP Toggle diagnostic virtual text (current line)" })
vim.keymap.set("n", "<leader>dV", toggle_virtual_lines, { desc = "DAP Toggle diagnostic virtual lines (current line)" })
