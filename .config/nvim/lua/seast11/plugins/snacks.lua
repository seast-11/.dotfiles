require("snacks").setup({
    explorer = { enabled = true },
    input = { enabled = true },
    indent = { enabled = true, char = "|" },
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
})

-- stylua: ignore start
vim.keymap.set("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Grep" })
vim.keymap.set("n", "<leader>fw", function() Snacks.picker.grep_word() end, { desc = "Grep Word" })
vim.keymap.set("n", "<leader>fc", function() Snacks.picker.command_history() end, { desc = "Command History" })
vim.keymap.set("n", "<leader>fn", function() Snacks.picker.notifications() end, { desc = "Notification History" })
vim.keymap.set("n", "<leader>fG", function() Snacks.picker.grep({ cwd = vim.fn.expand("%:p:h") }) end, { desc = "Grep current dir" })
vim.keymap.set("n", "<leader>fB", function() Snacks.picker.grep({ glob = vim.fn.expand("%:t") }) end, { desc = "Grep current buffer" })
vim.keymap.set("n", "<leader>lg", function() Snacks.lazygit() end, { desc = "Lazygit" })
vim.keymap.set("n", "<leader>ef", function() Snacks.explorer() end, { desc = "File Explorer" })
vim.keymap.set("n", "<leader>fd", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>fD", function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics" })
vim.keymap.set("n", "<leader>fm", function() Snacks.picker.marks() end, { desc = "Marks" })
vim.keymap.set("n", "<leader>fq", function() Snacks.picker.qflist() end, { desc = "Quickfix List" })
vim.keymap.set("n", "<leader>fr", function() Snacks.picker.resume() end, { desc = "Resume" })
vim.keymap.set("n", "<leader>fu", function() Snacks.picker.undo() end, { desc = "Undo History" })
vim.keymap.set("n", "<leader>fk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
vim.keymap.set("n", "<leader>gD", function() Snacks.picker.lsp_declarations() end, { desc = "Goto Declaration" })
vim.keymap.set("n", "<leader>gr", function() Snacks.picker.lsp_references() end, { desc = "References" })
vim.keymap.set("n", "<leader>gI", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
vim.keymap.set("n", "<leader>gy", function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto Type/Type Definition" })
vim.keymap.set("n", "<leader>gs", function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
-- stylua: ignore end
