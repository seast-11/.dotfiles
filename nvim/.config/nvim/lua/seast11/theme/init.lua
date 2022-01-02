local M = {}

M.colorscheme = "tokyonight"

vim.cmd("colorscheme " .. M.colorscheme)

if vim.loop.os_uname().sysname == "Linux" then
	vim.o.guifont = "JetBrainsMono\\ Nerd\\ Font\\ 14"
else
	vim.o.guifont = "JetBrainsMono NF:h14"
end

return M
