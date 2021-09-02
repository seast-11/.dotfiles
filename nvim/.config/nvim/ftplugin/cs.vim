" Terminal commands
nnoremap <C-b>  :!dotnet build<CR>
"nnoremap <F5>  :!dotnet run<CR>

" Tell ALE to use OmniSharp for linting C# files, and no other linters.
let g:ale_linters = { 'cs': ['OmniSharp'] }

" Basic Omni settings
let g:omnicomplete_fetch_full_documentation = 1
let g:OmniSharp_autoselect_existing_sln = 1
let g:OmniSharp_popup_position = 'peek'
let g:OmniSharp_highlighting = 3
let g:OmniSharp_diagnostic_exclude_paths = [ 'Temp[/\\]', 'obj[/\\]', '\.nuget[/\\]' ]

" Snippet integration
let g:OmniSharp_want_snippet = 1

" FZF integration
let g:OmniSharp_selector_ui = 'fzf'    
let g:OmniSharp_selector_findusages = 'fzf'
let g:OmniSharp_fzf_options = { 'down': '10' }

" Sharpenup integration
let g:sharpenup_codeactions_autocmd = 'CursorHold'
let g:sharpenup_create_mappings = 0

" C# mappings
nmap gd <Plug>(omnisharp_go_to_definition)
nmap <F2> <Plug>(omnisharp_rename)
nmap <Leader>fx <Plug>(omnisharp_code_actions)
xmap <Leader>fx <Plug>(omnisharp_code_actions)
nmap <Leader>cf <Plug>(omnisharp_code_format)
nmap <Leader>fi <Plug>(omnisharp_find_implementations)
nmap <Leader>fs <Plug>(omnisharp_find_symbol)
nmap <Leader>fu <Plug>(omnisharp_find_usages)
nmap <Leader>dc <Plug>(omnisharp_documentation)
nmap <Leader>gc <Plug>(omnisharp_global_code_check)
nmap <Leader>rt <Plug>(omnisharp_run_test)
nmap <Leader>rT <Plug>(omnisharp_run_tests_in_file)
nmap <Leader>ss <Plug>(omnisharp_start_server)
nmap <Leader>sp <Plug>(omnisharp_stop_server)
nmap <Leader>sh <Plug>(omnisharp_signature_help)
imap <Leader>sh <Plug>(omnisharp_signature_help)
