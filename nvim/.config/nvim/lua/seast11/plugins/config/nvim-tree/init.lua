vim.cmd("nnoremap <C-n> :NvimTreeToggle<CR>")

require("nvim-tree").setup({
  git = {
    ignore = true
  },
  actions = {
    open_file = {
      quit_on_open = true
    }
  },
  renderer = {
    indent_markers = {
      enable = true
    }
  }
})
