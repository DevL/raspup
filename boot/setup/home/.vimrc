syntax on
set number
set nowrap
set textwidth=100
set showmatch
set hlsearch
set smartcase
set ignorecase
set incsearch
set autoindent
set expandtab
set shiftwidth=4
set smartindent
set smarttab
set softtabstop=4
set ruler
set undolevels=1000
set backspace=indent,eol,start
set rtp+=/usr/local/opt/fzf
nnoremap tn : tabnew<Space>
nnoremap tk : tabnext<CR>
nnoremap tj : tabprev<CR>
nnoremap th : tabfirst<CR>
nnoremap tl : tablast<CR>
nnoremap ts : tab split<
nnoremap * m`:keepjumps normal!
nnoremap <CR> :nohlsearch<CR>
nnoremap tm : TableModeToggle<CR>
:au FocusLost * :wa
