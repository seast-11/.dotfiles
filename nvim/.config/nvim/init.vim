if has('win32')
    source $HOME/Appdata/Local/nvim/settings.vim
    let $PATH = "C:\\Program Files\\Git\\usr\\bin;" . $PATH
else
    source $HOME/.config/nvim/settings.vim
endif

call plug#begin()

Plug 'OmniSharp/omnisharp-vim'                              " C# enthusiams. Enthusiams. Enthusiams.
Plug 'nickspoons/vim-sharpenup'                             " C# fine tuning
Plug 'dense-analysis/ale'                                   " Linting Pale Ale
Plug 'morhetz/gruvbox'                                      " Far out, man!
Plug 'itchyny/lightline.vim'                                " Status bar 
Plug 'maximbaz/lightline-ale'                               " Pale Ale status bar integration
Plug 'prabirshrestha/asyncomplete.vim'                      " Completions
Plug 'SirVer/ultisnips'                                     " Snippet engine
Plug 'honza/vim-snippets'                                   " Snippets collection
Plug 'preservim/nerdtree'                                   " File explorer
Plug 'puremourning/vimspector'                              " VIM debugger! 
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }         " Fuzzy Wuzzy Was A File?
Plug 'junegunn/fzf.vim'                                     " Fuzzy Wuzzy Vim
Plug 'tpope/vim-fugitive'                                   " Git plugin
Plug 'mhinz/vim-signify'                                    " Show Git changes in status column
Plug 'tpope/vim-rhubarb'                                    " Enable :GBrowse to jump to github
Plug 'junegunn/gv.vim'                                      " Git commit browser
Plug 'preservim/nerdcommenter'                              " Line comment 
Plug 'norcalli/nvim-colorizer.lua'                          " Color highlighter

call plug#end()

if has('win32')
    source $HOME/Appdata/Local/nvim/mappings.vim
    source $HOME/Appdata/Local/nvim/plugs.vim
else
    source $HOME/.config/nvim/mappings.vim
    source $HOME/.config/nvim/plugs.vim
endif
