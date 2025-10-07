-- lua/seast11/core/colors.lua

local M = {}

local color_schemes = {
	"catppuccin",
	"solarized-osaka",
	"gruvbox",
	"tokyonight",
	"vscode",
	"cyberdream",
}

local color_scheme_file = vim.fn.stdpath("data") .. "/colorscheme.txt"

-- Save last used scheme
local function save_colorscheme(scheme)
	local f = io.open(color_scheme_file, "w")
	if f then
		f:write(scheme)
		f:close()
	end
end

-- Load from disk
local function load_last_colorscheme()
	local f = io.open(color_scheme_file, "r")
	if not f then
		return color_schemes[1]
	end
	local scheme = f:read("*l")
	f:close()
	if scheme and vim.fn.index(color_schemes, scheme) ~= -1 then
		return scheme
	end
	return color_schemes[1]
end

-- Internal state
M.current_scheme = load_last_colorscheme()
M.current_index = vim.fn.index(color_schemes, M.current_scheme)
if M.current_index == -1 then
	M.current_index = 1
end

-- Toggle function
function M.toggle()
	M.current_index = (M.current_index % #color_schemes) + 1
	local scheme = color_schemes[M.current_index]
	local ok = pcall(vim.cmd.colorscheme, scheme)
	if ok then
		save_colorscheme(scheme)
		vim.defer_fn(function()
			vim.notify("🎨 Switched to: " .. scheme, vim.log.levels.INFO)
		end, 100)
	else
		vim.notify("❌ Failed to load colorscheme: " .. scheme, vim.log.levels.ERROR)
	end
end

-- Apply scheme after plugins load (Lazy.nvim)
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		local ok = pcall(vim.cmd.colorscheme, M.current_scheme)
		if not ok then
			vim.cmd.colorscheme(color_schemes[1])
		end
	end,
})

-- Notify current colorscheme
function M.notify_current()
	vim.notify("Current colorscheme: " .. (M.current_scheme or color_schemes[1]), vim.log.levels.INFO)
end

-- ✅ Set keymap safely (after everything else is ready)
vim.api.nvim_create_autocmd("User", {
	pattern = "LazyDone", -- supposed to load last so other plugins finish
	callback = function()
		vim.keymap.set("n", "<leader>cc", M.toggle, { desc = "Toggle colorscheme" })
		vim.keymap.set("n", "<leader>cC", M.notify_current, { desc = "Show current colorscheme" })
	end,
})

return M
