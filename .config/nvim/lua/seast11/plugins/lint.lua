local lint = require("lint")

-- Tell luacheck which globals to expect (Neovim's vim, plus opts)
lint.linters.luacheck.args = {
    "--formatter", "plain",
    "--codes",
    "--ranges",
    "--globals", "vim,opts",
    "-",
}

lint.linters_by_ft = {
    lua = { "luacheck" },
    sh = { "shellcheck" },
    zsh = { "shellcheck" },
    bash = { "shellcheck" },
    python = { "ruff" },
    c = { "cppcheck" },
    cpp = { "cppcheck" },
}

-- no automatic linting — only manual via keymap
vim.keymap.set("n", "<leader>ml", function()
    lint.try_lint()
end, { desc = "Trigger linting for current file" })
