vim.g.mapleader = " "
vim.g.maplocalleader = " "

local options = { noremap = true, silent = false }
local keymap = vim.api.nvim_set_keymap

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",- space as the leader key

-- faster way to ESC
keymap("i", "ii", "<ESC>", options)

-- select all
keymap("n", "<C-a>", "ggVG", options)

-- better resizing
keymap("n", "<M-j>", ":resize -2<CR>", options)
keymap("n", "<M-k>", ":resize +2<CR>", options)
keymap("n", "<M-h>", ":vertical resize -2<CR>", options)
keymap("n", "<M-l>", ":vertical resize +2<CR>", options)

-- better window navigation
keymap("n", "<C-h>", "<C-w>h", options)
keymap("n", "<C-j>", "<C-w>j", options)
keymap("n", "<C-k>", "<C-w>k", options)
keymap("n", "<C-l>", "<C-w>l", options)

-- use tabs to navigate buffers
keymap("n", "<Tab>", ":bnext<CR>", options)
keymap("n", "<S-Tab>", ":bprevious<CR>", options)

-- better indenting
keymap("v", "<", "<gv", options)
keymap("v", ">", ">gv", options)

-- quick list shortcuts
keymap("n", "<C-c>", ":cclose<CR>", options)
keymap("n", "<C-j>", ":cnext<CR>", options)
keymap("n", "<C-k>", ":cprev<CR>", options)

-- close all buffers except the active one
keymap("n", "<leader>bd", ":%bd|e#|bd#<CR>", options)

-- make copy/paste work like a human would expect it to!
keymap("v", "p", '"_dP', options)

-- move text up and down for normal/visual/visual block modes
keymap("n", "<A-j>", "<Esc>:m .+1<CR>==", options)
keymap("n", "<A-k>", "<Esc>:m .-2<CR>==", options)
keymap("v", "<A-j>", ":m .+1<CR>==", options)
keymap("v", "<A-k>", ":m .-2<CR>==", options)
keymap("x", "J", ":move '>+1<CR>gv-gv", options)
keymap("x", "K", ":move '<-2<CR>gv-gv", options)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", options)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", options)
