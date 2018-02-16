" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

runtime bundle/vim-pathogen/autoload/pathogen.vim

set background=dark
colorscheme desert
syntax enable
if $COLORTERM == 'gnome-terminal'
    set t_Co=256
endif

set encoding=utf8
set ffs=unix,dos,mac

set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set shiftwidth=4    " number of spaces changed when << and >> are used
set expandtab       " tabs are spaces
set smarttab

set linebreak
set textwidth=0
set autoindent
set smartindent
set wrap

set number                      " show line numbers
set backspace=indent,eol,start  " allow backspace in insert mode
set showcmd                     " show command in bottom bar
set noshowmode                    " show current mode down the bottom
set history=1000                " store lots of :cmdline history
set cursorline                  " highlight current line
filetype plugin on              " load filetype-sepcific plugin files
filetype indent on              " load filetype-specific indent files
set visualbell t_vb=            " no sounds
set autoread                    " reload files changed outside vim
set wildmenu                    " visual autocomplete for command menu
set lazyredraw                  " redraw only when we need to.
set showmatch                   " highlight matching [{()}]
set hidden                      " makes buffers remember undo and marks
set title                       " sets the terminal title
set scrolloff=5                 " sets the min context lines when scrolling
set ruler
set cmdheight=2
set whichwrap+=<,>
set foldcolumn=1
set nobackup
set nowb
set noswapfile
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L

set laststatus=2
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c

set incsearch           " search as characters are entered
set hlsearch            " highlight matches
set ignorecase
set smartcase
set magic

try
    set undodir=~/.vim/undodir
    set undofile
catch
endtry

set foldenable          " enable folding
set foldlevelstart=10   " open most folds by default
set foldnestmax=10      " 10 nested fold max
set foldmethod=indent   " fold based on indent level

let mapleader=","       " leader is comma
let g:mapleader = ","
" edit and load vimrc
map <leader>e :e! $MYVIMRC<CR>
nmap <leader>w :w!<CR>
" invert 0 and ^
noremap 0 ^
noremap ^ 0

augroup configgroup
    autocmd!
    autocmd VimEnter * highlight clear SignColumn
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    autocmd BufWritePost ~/.vimrc source ~/.vimrc
    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
    autocmd BufEnter *.zsh-theme setlocal filetype=zsh
    autocmd BufEnter Makefile setlocal noexpandtab
    autocmd BufEnter *.sh setlocal tabstop=2
    autocmd BufEnter *.sh setlocal shiftwidth=2
    autocmd BufEnter *.sh setlocal softtabstop=2
augroup END

" Delete trailing white space on save, useful for some filetypes ;)
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    endif
    return ''
endfunction

set diffopt=vertical,filler

let python_highlight_all = 1
augroup pythongroup
    au FileType python syn keyword pythonDecorator True None False self

    au BufNewFile,BufRead *.jinja set syntax=htmljinja
    au BufNewFile,BufRead *.mako set ft=mako

    au FileType python map <buffer> F :set foldmethod=indent<cr>

    au FileType python set cindent
    au FileType python set cinkeys-=0#
    au FileType python set indentkeys-=0#
    au FileType python setlocal colorcolumn=80
augroup END

execute pathogen#infect()
call pathogen#helptags()

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_theme='murmur'
set ttimeoutlen=10

let MRU_Max_Entries = 400
map <leader>f :MRU<CR>

map <leader>l :GV<CR>

if has('python3')
    let g:gundo_prefer_python3 = 1
endif
nnoremap <leader>u :GundoToggle<CR>

let g:jellybeans_use_term_italics = 1
let g:jellybeans_overrides = {
\    'background': { 'ctermbg': 'none', '256ctermbg': 'none' },
\}
colorscheme jellybeans
highlight ColorColumn ctermbg=8

let g:syntastic_python_checkers = ['flake8']
