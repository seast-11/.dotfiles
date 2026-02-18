return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		explorer = { enabled = true },
		input = { enabled = true },
		indent = { enabled = true, char = "┊" },
		statuscolumn = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = true },
		notifier = { enabled = true },
		lazygit = { enabled = true },
		picker = {
			layout = {
				width = 0.99,
				height = 0.9,
				min_width = 150,
			},
			sources = {
				explorer = {
          hidden = true,
					jump = { close = true },
				},
			},
		},
	},
	keys = {
    -- stylua: ignore start
    -- Find
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>fc", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>fn", function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<leader>fG", function() Snacks.picker.grep({ cwd = vim.fn.expand("%:p:h") }) end, desc = "Grep current dir" },
    { "<leader>fB", function() Snacks.picker.grep({ glob = vim.fn.expand("%:t") }) end, desc = "Grep current buffer" },

    -- lazygit
    { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },

    -- Explorer
    { "<leader>ef", function() Snacks.explorer() end, desc = "File Explorer" },
   
    -- search
    { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>fD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
    { "<leader>fm", function() Snacks.picker.marks() end, desc = "Marks" },
    { "<leader>fq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
    { "<leader>fr", function() Snacks.picker.resume() end, desc = "Resume" },
    { "<leader>fu", function() Snacks.picker.undo() end, desc = "Undo History" },
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
   
    -- LSP
    { "<leader>gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
    { "<leader>gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
    { "<leader>gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
    { "<leader>gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
    { "<leader>gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
    { "<leader>gs", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
		-- stylua: ignore end
	},
}
