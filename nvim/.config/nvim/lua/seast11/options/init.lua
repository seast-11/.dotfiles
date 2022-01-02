vim.cmd("filetype plugin indent on")

vim.o.backspace = "indent,eol,start"
vim.o.completeopt = "menuone,noinsert,noselect"
vim.o.clipboard = "unnamedplus"
vim.o.shortmess = vim.o.shortmess .. 'c'
vim.o.mouse = "a"
vim.o.hidden = true
vim.o.showmatch = true
vim.o.fileencoding = "utf-8"
vim.o.cmdheight = 2
vim.o.termguicolors = true
vim.o.conceallevel = 0
vim.o.showtabline = 2
vim.o.showmode = false
vim.o.backup = false
vim.o.writebackup = false
vim.o.updatetime = 50
vim.o.timeoutlen = 500
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.scrolloff = 8
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.smarttab = true
vim.o.smartindent = true
vim.o.laststatus = 2
vim.o.wildmenu = true
vim.o.swapfile = false
vim.o.autoindent = true
vim.o.expandtab = true

vim.wo.wrap = false
vim.wo.number = true
vim.wo.cursorline = true
vim.wo.signcolumn = "yes"
vim.wo.colorcolumn = "100"

vim.bo.autoindent = true
vim.bo.expandtab = true
