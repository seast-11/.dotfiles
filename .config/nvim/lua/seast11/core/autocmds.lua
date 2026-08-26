local function highlight_symbol(event)
	local client = vim.lsp.get_client_by_id(event.data.client_id)
	if not client or not client:supports_method("textDocument/documentHighlight") then
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

local function dim_inactive_hl()
    local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
    local bg = normal.bg
    if bg then
        -- Solid background: dim it by 40%
        local r = bit.rshift(bg, 16)
        local g = bit.rshift(bg, 8)
        local b = bg
        r = math.max(0, math.floor(bit.band(r, 0xff) * 0.6))
        g = math.max(0, math.floor(bit.band(g, 0xff) * 0.6))
        b = math.max(0, math.floor(bit.band(b, 0xff) * 0.6))
        local dimmed = r * 0x10000 + g * 0x100 + b
        vim.api.nvim_set_hl(0, "InactiveWindow", { bg = dimmed })
    else
        -- Transparent background: use dimmed fg as a faint bg
        local fg = normal.fg
        if fg then
            local r = bit.rshift(fg, 16)
            local g = bit.rshift(fg, 8)
            local b = fg
            r = math.max(0, math.floor(bit.band(r, 0xff) * 0.08))
            g = math.max(0, math.floor(bit.band(g, 0xff) * 0.08))
            b = math.max(0, math.floor(bit.band(b, 0xff) * 0.08))
            local dimmed = r * 0x10000 + g * 0x100 + b
            vim.api.nvim_set_hl(0, "InactiveWindow", { bg = dimmed })
        else
            vim.api.nvim_set_hl(0, "InactiveWindow", {})
        end
    end
end

dim_inactive_hl()

-- Recalculate when colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = dim_inactive_hl,
})

local function set_focus_highlights(active)
    local hl = active
        and "Normal:Normal,NormalNC:InactiveWindow"
        or "Normal:InactiveWindow,NormalNC:InactiveWindow"

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        vim.api.nvim_set_option_value("winhighlight", hl, { win = win })
    end
end

vim.api.nvim_create_autocmd("FocusGained", {
    callback = function()
        set_focus_highlights(true)
    end,
})

vim.api.nvim_create_autocmd("FocusLost", {
    callback = function()
        set_focus_highlights(false)
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "text", "markdown", "gitcommit" },
    callback = function()
        vim.opt_local.wrap = true
    end,
})
