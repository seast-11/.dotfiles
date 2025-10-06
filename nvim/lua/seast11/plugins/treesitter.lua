return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		local treesitter = require("nvim-treesitter.configs")

		treesitter.setup({
			ensure_installed = {
				"bash",
				"c",
				"c_sharp",
				"css",
				"dockerfile",
				"gitignore",
				"go",
				"graphql",
				"html",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"prisma",
				"query",
				"regex",
				"rust",
				"svelte",
				"vim",
				"vimdoc",
				"yaml",
			},

			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},

			indent = { enable = true },

			autotag = { enable = true },

			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					node_decremental = "<bs>",
					scope_incremental = false,
				},
			},

			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]m"] = "@function.outer",
						["]]"] = "@class.outer",
					},
					goto_previous_start = {
						["[m"] = "@function.outer",
						["[["] = "@class.outer",
					},
				},
			},
		})

		-- 🧩 Native Treesitter folding
		vim.opt.foldmethod = "expr"
		vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.opt.foldenable = false
		vim.opt.foldlevel = 99
	end,
}
