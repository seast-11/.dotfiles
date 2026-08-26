-- Plugin management via vim.pack (Neovim 0.12+)
vim.pack.add({
    -- core
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/christoomey/vim-tmux-navigator",

    -- snacks (picker, explorer, lazygit, notifier, indent, scroll, etc.)
    "https://github.com/folke/snacks.nvim",

    -- completion
    { src = "https://github.com/saghen/blink.cmp", version = "v1" },
    "https://github.com/rafamadriz/friendly-snippets",

    -- formatting & linting
    "https://github.com/stevearc/conform.nvim",
    "https://github.com/mfussenegger/nvim-lint",

    -- treesitter is built-in to Neovim 0.12, no plugin needed
    -- parsers can be installed via :TSInstall or TSInstallMason below

    -- colorschemes
    "https://github.com/folke/tokyonight.nvim",
    "https://github.com/Mofiqul/vscode.nvim",
    "https://github.com/catppuccin/nvim",
    "https://github.com/craftzdog/solarized-osaka.nvim",
    "https://github.com/rebelot/kanagawa.nvim",
    "https://github.com/EdenEast/nightfox.nvim",
    "https://github.com/navarasu/onedark.nvim",
    "https://github.com/sainnhe/gruvbox-material",
    "https://github.com/sainnhe/sonokai",

    -- UI
    "https://github.com/folke/which-key.nvim",
    "https://github.com/catgoose/nvim-colorizer.lua",
    "https://github.com/nvim-lualine/lualine.nvim",

    -- DAP
    "https://github.com/mfussenegger/nvim-dap",
    "https://github.com/igorlfs/nvim-dap-view",
    "https://github.com/leoluz/nvim-dap-go",
})

    -- Plugin configs
    require("seast11.plugins.snacks")
    require("seast11.plugins.blink")
    require("seast11.plugins.conform")
    require("seast11.plugins.lint")

    require("seast11.plugins.which-key")
    require("seast11.plugins.colorizer")
    require("seast11.plugins.lualine")
    require("seast11.plugins.dap")
