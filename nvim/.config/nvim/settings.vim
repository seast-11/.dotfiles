syntax enable                                   " Enables syntax highlighing
filetype plugin indent on                       " Required for plugins

set path+=**				                    " Search current directory recursively
set hidden                                      " Required to keep multiple buffers open multiple buffers
set nowrap                                      " Display long lines as just one line
set nohlsearch                                  " Don't highlight search
set encoding=utf-8                              " The encoding displayed
set pumheight=10                                " Makes popup menu smaller
set fileencoding=utf-8                          " The encoding written to file
set ruler              			                " Show the cursor position all the time
set cmdheight=2                                 " More space for displaying messages
set iskeyword+=-                      	        " treat dash separated words as a word text object"
set mouse=a                                     " Enable your mouse
set splitbelow                                  " Horizontal splits will automatically be below
set splitright                                  " Vertical splits will automatically be to the right
set termguicolors                               " Support 256 colors
set conceallevel=0                              " So that I can see `` in markdown files
set tabstop=4                                   " Insert 4 spaces for a tab
set softtabstop=4                               " More tab propaganda
set shiftwidth=4                                " Change the number of space characters inserted for indentation
set smarttab                                    " Makes tabbing smarter will realize you have 2 vs 4
set expandtab                                   " Converts tabs to spaces
set smartindent                                 " Makes indenting smart
set autoindent                                  " Good auto indent
set laststatus=2                                " Always display the status line
set number                                      " Line numbers
set cursorline                                  " Enable highlighting of the current line
set background=dark                             " tell vim what the background color looks like
set showtabline=1                               " Always show tabs
set nobackup                                    " No auto backups
set noswapfile				                    " No swap
set nowritebackup                               " This is recommended by coc
set updatetime=50                               " Faster completion
set timeoutlen=500                              " By default timeoutlen is 1000 ms
set clipboard=unnamedplus                       " Copy paste between vim and everything else
set ignorecase smartcase                        " Search case-insensitively unless uppercase characters are used
set wildmenu				                    " Display all matches when tab complete
set incsearch				                    " Highlight search results as typed
set wildmode=longest,list,full		            " Nice menu when typing `:find *.py`
set guicursor=				                    " Disable gui cursor
set undodir=~/.local/share/nvim/undodir	        " Undo location
set undofile				                    " Undo
set colorcolumn=80                              " Visual indicator of 80th columns
set scrolloff=8                                 " Better scrolling
set signcolumn=yes                              " Show messages in gutter
set completeopt=menuone,noinsert,noselect       " Menu options
set backspace=indent,eol,start                  " Make backspace work correctly

" Ignore files
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/android/*
set wildignore+=**/ios/*
set wildignore+=**/.git/*
