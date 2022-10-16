-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_seast11_config
    autocmd!
    autocmd BufWritePost lua/seast11/plugins/init.lua source <afile> | PackerSync
  augroup end
]])

local packer = require("packer")

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

return packer.startup(function()
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	-- Groovy themes! Far out, Ralph!
	use("sainnhe/gruvbox-material")
	use("morhetz/gruvbox")
	use("folke/tokyonight.nvim")

	-- Awesome TreeSitter for better syntax highlighting
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })

	-- Lua based file explorer with Nerd fonts
	use({ "kyazdani42/nvim-tree.lua", requires = { "kyazdani42/nvim-web-devicons" } })

	-- Lua based status line
	use({ "nvim-lualine/lualine.nvim", requires = { "kyazdani42/nvim-web-devicons" } })

	-- Better tabs
	use({ "akinsho/bufferline.nvim", tag = "v2.*", requires = "kyazdani42/nvim-web-devicons" })

	-- TreeSitter plugin for better brace/bracket highlighting
	use({ "p00f/nvim-ts-rainbow" })

	-- Generate brace/bracket pairs
	use({ "windwp/nvim-autopairs" })

	-- Popup for frequent commands
	--use {'folke/which-key.nvim'}

	-- Powerful fzf finder
	use({ "nvim-telescope/telescope.nvim", requires = { { "nvim-lua/plenary.nvim" } } })

	-- LSP plugins
	use("neovim/nvim-lspconfig")
	use("hrsh7th/nvim-cmp")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/cmp-nvim-lua")
	use("onsails/lspkind-nvim")
	use("ray-x/lsp_signature.nvim")
	use("saadparwaiz1/cmp_luasnip")
	use("tamago324/nlsp-settings.nvim")
  use({"glepnir/lspsaga.nvim", branch = "main"})

	-- Snippets engine and tons of snippets
	use("rafamadriz/friendly-snippets")
	use("L3MON4D3/LuaSnip")

	-- OmniSharp specifics
	-- use 'Hoffs/omnisharp-extended-lsp.nvim'

	-- Formatter to make files pretty
	use("jose-elias-alvarez/null-ls.nvim")

	-- Commenter
	use("terrortylor/nvim-comment")

	-- Color for hex
	use("norcalli/nvim-colorizer.lua")

	-- Git fugative and signs for gutter
	use({ "lewis6991/gitsigns.nvim", requires = { "nvim-lua/plenary.nvim" } })
	use("tpope/vim-fugitive")

	-- Vertical ligns and context highlighting
	use("lukas-reineke/indent-blankline.nvim")
end)
