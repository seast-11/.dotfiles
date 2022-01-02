vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_quit_on_open = 1
vim.cmd("nnoremap <C-n> :NvimTreeToggle<CR>")

require("nvim-tree").setup({
	auto_open = 1,
	auto_close = 1,
	gitignore = 1,
})
