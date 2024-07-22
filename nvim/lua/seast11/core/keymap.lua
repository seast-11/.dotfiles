vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Step 1: Define your default options
local default_opts = { noremap = true, silent = true }

-- Step 2: Function to merge tables
local function merge_tables(tbl1, tbl2)
	local result = {}
	for k, v in pairs(tbl1) do
		result[k] = v
	end
	for k, v in pairs(tbl2) do
		result[k] = v
	end
	return result
end

-- Step 3: Set keymaps with specific options
local function set_keymap(mode, lhs, rhs, opts)
	opts = merge_tables(default_opts, opts)
	vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

set_keymap("i", "ii", "<ESC>", { desc = "Exit insert mode with ii" })

-- select all
set_keymap("n", "<C-a>", "ggVG", { desc = "Ctrl-a select all" })

-- better resizing
set_keymap("n", "<M-j>", ":resize -2<CR>", { desc = "resize horizontal down" })
set_keymap("n", "<M-k>", ":resize +2<CR>", { desc = "resize horizontal up" })
set_keymap("n", "<M-h>", ":vertical resize -2<CR>", { desc = "resize vertial down" })
set_keymap("n", "<M-l>", ":vertical resize +2<CR>", { desc = "resize vetical up" })

-- window management
set_keymap("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
set_keymap("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
set_keymap("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
set_keymap("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

set_keymap("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
set_keymap("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
set_keymap("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
set_keymap("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
set_keymap("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- better window navigation
set_keymap("n", "<C-h>", "<C-w>h", { desc = "resize vetical up" })
set_keymap("n", "<C-j>", "<C-w>j", { desc = "resize vetical up" })
set_keymap("n", "<C-k>", "<C-w>k", { desc = "resize vetical up" })
set_keymap("n", "<C-l>", "<C-w>l", { desc = "resize vetical up" })

-- better indenting
set_keymap("v", "<", "<gv", { desc = "shift text out" })
set_keymap("v", ">", ">gv", { desc = "shift text in" })

-- quick list shortcuts
set_keymap("n", "<C-c>", ":cclose<CR>", { desc = "close quick list" })
set_keymap("n", "<C-j>", ":cnext<CR>", { desc = "next quick list" })
set_keymap("n", "<C-k>", ":cprev<CR>", { desc = "prev quick list" })

-- close all buffers except the active one
set_keymap("n", "<leader>bd", ":%bd|e#|bd#<CR>", { desc = "close all other buffers" })

-- make copy/paste work like a human would expect it to!
set_keymap("v", "p", '"_dP', { desc = "make paste work like it should" })
