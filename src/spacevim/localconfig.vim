func! localcustomconfig#before() abort  "" global
  let $LANG="en_GB.UTF-8"
  set shell=fish

  let g:srcery_italic = 1
  let g:Lf_WindowPosition = 'popup'
  let g:Lf_PreviewInPopup = 1

  au BufRead,BufNewFile *.nix set filetype=nix
  au FileType nix setlocal foldmethod=marker
endf

func! localcustomconfig#after() abort  "" global
  let g:EditorConfig_exclude_patterns = ["fugitive://.*", "scp://.*"]
 
  set noswapfile
  set nobackup
  set nowb
 
  set smartcase
  set ignorecase
 
  noremap gw gw
  noremap gq gq
 
  set expandtab
  let g:neoformat_run_all_formatters = 1
  set sidescrolloff=0
 
  "" persistent_undo
  if !isdirectory("$HOME/.local/share/spacevim/backup")
      silent !mkdir "$HOME/.local/share/spacevim/backup" > /dev/null 2>&1
  endif
  set undodir=$HOME/.local/share/spacevim/backup
  set undofile
 
  "" python_plugins
  let g:spacevim_buffer_index_type = 1
  let g:neomake_python_enabled_makers = ["flake8"]
  let g:neoformat_enabled_python = ["docformatter", "black"]
  let g:neoformat_python_docformatter = {
      \ 'args': ['--wrap-descriptions', &textwidth, '- '],
      \ 'stdin': 1,
      \ 'exe': '@docformatter@'
      \ }
  let g:neoformat_python_isort = {
      \ 'args': ['- ', '--quiet'],
      \ 'stdin': 1,
      \ 'exe': '@isort@'
      \ }
  let g:neoformat_python_black = {
      \ 'exe': '@black@',
      \ 'stdin': 1,
      \ 'args': ['-q', '-'],
      \ }
  let g:dash_map.python = ['python', 'xarray', 'numpy', 'pandas', 'tensorflow']
  let g:slime_target = "neovim"
  let g:slime_paste_file = tempname()
  let g:slime_python_ipython = 1


  "" C/CPP
  let g:neoformat_c_clangformat = neoformat#formatters#c#clangformat()
  let g:neoformat_c_clangformat.exe = "/usr/local/Cellar/llvm/10.0.1_1/bin/clang-format"
  let g:neoformat_c_clangformat.args = ["--style=file"]
  let g:neoformat_cpp_clangformat = neoformat#formatters#cpp#clangformat()
  let g:neoformat_cpp_clangformat.exe = "/usr/local/Cellar/llvm/10.0.1_1/bin/clang-format"
  let g:neoformat_cpp_clangformat.args = ["--style=file"]

  "" nix stuff
  let g:neoformat_nix_nixfmt = neoformat#formatters#nix#nixfmt()
  let g:neoformat_nix_nixfmt.exe = '@nixfmt@'
  let g:neoformat_enabled_nix = ["nixfmt"]
  let g:neomake_python_flake8_maker = neomake#makers#ft#python#flake8()
  let g:neomake_python_flake8_maker.exe = "@flake8@"
  let g:neomake_python_mypy_maker = neomake#makers#ft#python#mypy()
  let g:neomake_python_mypy_maker.exe = "@mypy@"

  """ rust
  let g:dash_map.rust = ['rust']

  "" pwd_vimrc
  if filereadable(".vimrc")
      exe "source .vimrc"
  endif
  if isdirectory(".vim") && filereadable(".vim/init.vim")
      exe "source .vim/init.vim"
  endif
 
  "" ignore-stuff
  let g:spacevim_wildignore='/tmp/*,*.so,*.swp,*.zip,*.class,tags,*.jpg'
  let g:spacevim_wildignore+='.ttf,*.TTF,*.png,*/target/*,.git,.svn,.hg'
  let g:spacevim_wildignore+='.DS_Store,*.svg,.tox/*,.vscode/*'
  let g:spacevim_wildignore+='.mypy_cache/*,.*-cache'
 
  "" terminal
  tnoremap <C-h> <C-\><C-N><C-w>h
  tnoremap <C-j> <C-\><C-N><C-w>j
  tnoremap <C-k> <C-\><C-N><C-w>k
  tnoremap <C-l> <C-\><C-N><C-w>l
  tnoremap jk <C-\><C-N>

  "" vim-zoom
  tmap <C-w>m <C-\><C-N><C-w>m
  nmap <space>z <C-w>m

  let g:cscope_cmd = "@cscope@"

  let g:tagbar_ctags_bin="@ctags@"

  " Use `[g` and `]g` to navigate diagnostics
  " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)

  " GoTo code navigation.
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)

  " Use K to show documentation in preview window.
  nnoremap <silent> K :call <SID>show_documentation()<CR>

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction

  " Highlight the symbol and its references when holding the cursor.
  set updatetime=500
  autocmd CursorHold * silent call CocActionAsync('highlight')
  highlight CocHighlightText ctermfg=LightMagenta guifg=LightMagenta
endf
