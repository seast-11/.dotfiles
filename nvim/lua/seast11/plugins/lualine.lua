return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		local function lsp_clients()
			local bufnr = vim.api.nvim_get_current_buf()
			local clients = vim.lsp.get_clients({ bufnr = bufnr })
			if #clients == 0 then
				return "󱙺 LSP"
			end
			local names = {}
			for _, client in ipairs(clients) do
				table.insert(names, client.name)
			end
			return "  " .. table.concat(names, ", ")
		end

		lualine.setup({
			options = {
				theme = "auto",
			},
			sections = {
				lualine_x = {
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						symbols = { error = " ", warn = " ", info = " ", hint = " " },
					},
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = "#ff9e64" },
					},
					{ lsp_clients },
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
				},
			},
		})
	end,
}
