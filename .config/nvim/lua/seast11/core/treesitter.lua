-- Treesitter is built-in to Neovim 0.12
-- Parsers are installed via the script at:
--   $NVIM_CONFIG_DIR/install_parsers.sh
--   (run it on a fresh machine to compile all parsers)

-- Register known filetype-to-language mappings for parsers installed with :TSInstall
vim.treesitter.language.register("bash", "bash")
vim.treesitter.language.register("c", "c")
vim.treesitter.language.register("c_sharp", "c_sharp")
vim.treesitter.language.register("css", "css")
vim.treesitter.language.register("go", "go")
vim.treesitter.language.register("html", "html")
vim.treesitter.language.register("json", "json")
vim.treesitter.language.register("lua", "lua")
vim.treesitter.language.register("markdown", "markdown")
vim.treesitter.language.register("query", "query")
vim.treesitter.language.register("regex", "regex")
vim.treesitter.language.register("rust", "rust")
vim.treesitter.language.register("svelte", "svelte")
vim.treesitter.language.register("vim", "vim")
vim.treesitter.language.register("yaml", "yaml")

-- Treesitter highlighting and folding are automatic in 0.12
-- No need for manual vim.treesitter.start() calls

-- Folding with treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false
vim.opt.foldlevel = 99

-- (Optional) If you want textobjects, consider:
--   - mini.ai (https://github.com/echasnovski/mini.ai)
--   - or keep nvim-treesitter-textobjects (archived but works)
-- The textobject mappings were removed since they caused the V-line stutter.
