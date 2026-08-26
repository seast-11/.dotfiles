local wk = require("which-key")

wk.setup({
    layout = {
        align = "center",
    },
    win = {
        border = "bold",
        padding = { 1, 1 },
        no_overlap = true,
    },
    preset = "helix",
})

wk.add({
    { "<leader>g", group = "LSP" },
    { "<leader>f", group = "The Telescopes" },
    { "<leader>e", group = "File Tree" },
    { "<leader>l", group = "LazyGit" },
    { "<leader>m", group = "Format & Lint" },
    { "<leader>b", group = "Buffer" },
    { "<leader>d", group = "DAP" },
    { "<leader>p", group = "PACK" },
    { "<leader>t", group = "Tabs" },
    { "<leader>s", group = "Sessions & Splits" },
    { "<leader>c", group = "BOB ROSS!" },
})
