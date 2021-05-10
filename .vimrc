" Common
colorscheme slate
set cursorline
set history=500
set hidden
set showcmd
set wildmenu
set ignorecase
set smartcase
set bg=dark
highlight Pmenu ctermbg=cyan guibg=cyan

"Mode Settings

" For Terminal
" let &t_SI.="\e[5 q" "SI = INSERT mode
" let &t_SR.="\e[4 q" "SR = REPLACE mode
" let &t_EI.="\e[1 q" "EI = NORMAL mode (ELSE)

" For tmux running in iTerm2
" let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
" let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
" let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"

" For iTerm2
" let &t_SI = "\<Esc>]50;CursorShape=1\x7"
" let &t_SR = "\<Esc>]50;CursorShape=2\x7"
" let &t_EI = "\<Esc>]50;CursorShape=0\x7"

"Cursor settings:

"  1 -> blinking block
"  2 -> solid block
"  3 -> blinking underscore
"  4 -> solid underscore
"  5 -> blinking vertical bar
"  6 -> solid vertical bar

" Software Development
set number
set lbr
set ai
set si
set softtabstop=4
set shiftwidth=4
set expandtab
set cursorline
augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  au WinLeave * setlocal nocursorline
augroup END
highlight CursorLine cterm=NONE ctermbg=23 
:hi CursorLine   cterm=NONE ctermbg=23
:nnoremap H :set cursorline! cursorcolumn!<CR>

"  Needed due to session restoration
function s:SetCursorLine()
    set cursorline
    hi cursorline cterm=none ctermbg=23
endfunction
autocmd VimEnter * call s:SetCursorLine()

" IDE'esque
:inoremap ( ()<Esc>:let leavechar=")"<CR>i
:inoremap [ []<Esc>:let leavechar="]"<CR>i
:inoremap { {<CR><BS>}<Esc>ko
map <C-o> :NERDTreeToggle<CR>
let g:syntastic_python_python_exec = 'python3'

" System Integration
let @c=':w !pbcopy' " copy (visual mode)
let @x=':!pbcopy'     " cut (visual mode)

" For Powerline
set laststatus=2
set t_Co=256
set encoding=utf-8
set guifont=SourceCodePro+Powerline+Awesome\ Regular
set fillchars+=stl:\ ,stlnc:\
set termencoding=utf-8

if has("gui_running")
  set gfn=SourceCodePro+Powerline+Awesome\ Regular:h12
  colorscheme slate
  set ruler
else
  set term=xterm-256color
endif

let g:Powerline_symbols='fancy'
let g:airline_powerline_fonts=1
let g:Powerline_symbols='unicode'
let g:airline_theme='wombat'


" Typescript is xml
autocmd BufNewFile,BufRead *.ts setlocal filetype=typescript

" Syntastic
let g:airline#extensions#syntastic#enabled = 1

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_typescript_checkers = ['tslint', 'tsc']
let g:syntastic_typescript_tsc_args = "-t ES5 -m commonjs --experimentalDecorators --emitDecoratorMetadata --sourceMap true --moduleResolution node"


" To hush imp warning in youcompleteme:
" the imp module is deprecated in favour of importlib
" if has('python3')
"    silent! python3 1
" endif
" if has('python3')
"    command! -nargs=1 Py py3 <args>
"    set pythonthreedll=/Users/rene/.homebrew/opt/python@3.8/Frameworks/Python.framework/Versions/Current/Python
"    set pythonthreehome=/Users/rene/.homebrew/opt/python3/Frameworks/Python.framework/Versions/Current
" else
"    command! -nargs=1 Py py <args>
"    set pythondll=/Users/rene/.homebrew/opt/python2/Frameworks/Python.framework/Versions/2.7/Python
"    set pythonhome=/Users/rene/.homebrew/opt/python2/Frameworks/Python.framework/Versions/2.7
" endif

call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'junegunn/vim-easy-align'
Plug 'junegunn/fzf'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'valloric/youcompleteme'
Plug 'airblade/vim-gitgutter'
Plug 'editorconfig/editorconfig-vim'

call plug#end()

