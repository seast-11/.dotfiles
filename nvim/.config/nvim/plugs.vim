" Gruvbox for theme!
colorschem gruvbox

" Enable color highlighting in CSS
lua require'colorizer'.setup()

" Debugger settings
let g:vimspector_enable_mappings = 'VISUAL_STUDIO'

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
nmap <C-\> <Plug>NERDCommenterToggle
vmap <C-\> <Plug>NERDCommenterToggle<CR>gv

" FZF
nnoremap <C-f> :Files<CR>
nnoremap <C-g> :GFiles<CR>
map <leader>b :Buffers<CR>
map <leader>g :Rg<CR>
let g:fzf_layout = {'up':'~90%', 'window': { 'width': 0.8, 'height': 0.8,'yoffset':0.5,'xoffset': 0.5, 'highlight': 'Todo', 'border': 'sharp' } }
let $FZF_DEFAULT_OPTS = '--layout=reverse --info=inline'

" Get text in files with Rg
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" File explorer toggle
nnoremap <C-t> :NERDTreeToggle<CR>

" Completion tab completion
inoremap <expr> <cr> pumvisible() ? asyncomplete#close_popup() : "\<cr>"

" Tab completion for snippets
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<S-tab>"

" Lightline status bar configuration
let g:lightline = {}
let g:sharpenup_statusline_opts = {
\ 'TextLoading': ' O#: %s loading... (%p of %P) ',
\ 'TextReady': ' O#: %s (%p/%P)',
\ 'TextDead': ' O#: Zeds Dead ',
\ 'Highlight': 1,
\ 'HiLoading': 'SharpenUpLoading',
\ 'HiReady': 'SharpenUpReady',
\ 'HiDead': 'SharpenUpDead'
\}
let g:lightline.component = { 'sharpenup': sharpenup#statusline#Build() }
let g:lightline.component_expand = {
      \  'linter_checking': 'lightline#ale#checking',
      \  'linter_infos': 'lightline#ale#infos',
      \  'linter_warnings': 'lightline#ale#warnings',
      \  'linter_errors': 'lightline#ale#errors',
      \  'linter_ok': 'lightline#ale#ok',
      \ }
let g:lightline.component_type = {
      \     'linter_checking': 'right',
      \     'linter_infos': 'right',
      \     'linter_warnings': 'warning',
      \     'linter_errors': 'error',
      \     'linter_ok': 'right',
      \ }
let g:lightline.component_function = { 'gitbranch': 'FugitiveHead' }
let g:lightline.active = { 
      \     'left': [ [ 'mode', 'paste' ], [ 'gitbranch', 'readonly', 'filename', 'modified' ] ], 
      \     'right': [ [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ], [ 'lineinfo' ], [ 'percent' ], [ 'fileformat', 'fileencoding', 'filetype', 'sharpenup' ] ] 
      \ }
let g:lightline.inactive = { 'right': [['lineinfo'], ['percent'], ['sharpenup']] }
