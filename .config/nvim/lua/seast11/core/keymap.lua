vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- exit insert mode
vim.keymap.set("i", "ii", "<ESC>", { silent = true, desc = "Exit insert mode with ii" })

-- select all
vim.keymap.set("n", "<C-a>", "ggVG", { silent = true, desc = "Select all" })

-- center search results
vim.keymap.set("n", "n", "nzz", { silent = true, desc = "Next search result, centered" })
vim.keymap.set("n", "N", "Nzz", { silent = true, desc = "Previous search result, centered" })

-- centering scroll
vim.keymap.set("n", "<C-d>", "<C-d>zz", { silent = true, desc = "Page down, centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { silent = true, desc = "Page up, centered" })

-- resizing splits
vim.keymap.set("n", "<M-j>", ":resize -2<CR>", { silent = true, desc = "Decrease window height" })
vim.keymap.set("n", "<M-k>", ":resize +2<CR>", { silent = true, desc = "Increase window height" })
vim.keymap.set("n", "<M-h>", ":vertical resize -2<CR>", { silent = true, desc = "Decrease window width" })
vim.keymap.set("n", "<M-l>", ":vertical resize +2<CR>", { silent = true, desc = "Increase window width" })

-- window management
vim.keymap.set("n", "<leader>sv", "<C-w>v", { silent = true, desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { silent = true, desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { silent = true, desc = "Make splits equal size" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { silent = true, desc = "Close current split" })
vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { silent = true, desc = "Open new tab" })
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { silent = true, desc = "Close current tab" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { silent = true, desc = "Go to next tab" })
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { silent = true, desc = "Go to previous tab" })
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { silent = true, desc = "Open current buffer in new tab" })

-- window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true, desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true, desc = "Move to window below" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true, desc = "Move to window above" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true, desc = "Move to right window" })

-- better indenting
vim.keymap.set("v", "<", "<gv", { silent = true, desc = "Shift selection left, keep selection" })
vim.keymap.set("v", ">", ">gv", { silent = true, desc = "Shift selection right, keep selection" })

-- quickfix
vim.keymap.set("n", "<C-c>", ":cclose<CR>", { silent = true, desc = "Close quickfix list" })

-- close all buffers except the active one
vim.keymap.set("n", "<leader>bd", ":%bd|e#|bd#<CR>", { silent = true, desc = "Close all other buffers" })

-- paste without yanking the replaced text
vim.keymap.set("v", "p", '"_dP', { silent = true, desc = "Paste over selection without overwriting register" })

-- Update all plugins immediately, no confirmation buffer
vim.keymap.set("n", "<leader>pu", function()
	vim.pack.update(nil, { force = true })
end, { desc = "Pack: update all plugins" })

-- Just see what's pending — opens the confirm buffer, don't write it
vim.keymap.set("n", "<leader>pc", function()
	vim.pack.update()
end, { desc = "Pack: check for updates" })
