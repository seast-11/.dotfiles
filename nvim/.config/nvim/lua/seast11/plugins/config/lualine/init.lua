local colorscheme = require("seast11.theme").colorscheme

require("lualine").setup({
	options = { theme = colorscheme, section_separators = "", component_separators = "" },
	extensions = { "nvim-tree" },
})
