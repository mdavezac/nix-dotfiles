" Comment the following line if you don't want Vim and NeoVim to share the
" same plugin download directory.
let g:spacevim_plug_home = '~/.local/neovim/plugged'

" Uncomment the following line to override the leader key. The default value is space key "<\Space>".
" let g:spacevim_leader = "<\Space>"

" Uncomment the following line to override the local leader key. The default value is comma ','.
" let g:spacevim_localleader = ','

" Enable the existing layers in space-vim.
" Refer to https://github.com/liuchengxu/space-vim/blob/master/layers/LAYERS.md for all available layers.
let g:spacevim_layers = [
      \ 'fzf', 'better-defaults', 'which-key',
      \ 'git', 'lsp', 'programming', 'lsp', 'tmux',
      \ 'syntax-checking', 'deoplete', 'emoji', 'python', 'ctags'
      \ ]

" Uncomment the following line if your terminal(-emulator) supports true colors.
let g:spacevim_enable_true_color = 1

" Uncomment the following if you have some nerd font installed.
let g:spacevim_nerd_fonts = 1

" If you want to have more control over the layer, try using Layer command.
" if g:spacevim.gui
"   Layer 'airline'
" endif

" Manage your own plugins.
" Refer to https://github.com/junegunn/vim-plug for more detials.
function! UserInit()

  " Add your own plugin via Plug command.
  Plug 'LnL7/vim-nix'

endfunction

" Override the default settings from space-vim as well as adding extras
function! UserConfig()

  " Adding extras.
  " Uncomment the following line If you have installed the powerline fonts.
  " It is good for airline layer.
  let g:airline_powerline_fonts = 1

  hi Comment cterm=italic
endfunction

