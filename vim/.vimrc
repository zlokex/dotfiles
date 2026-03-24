" __   ___
" \ \ / (_)_ __
"  \ V /| | '  \
"   \_/ |_|_|_|_|
"
"


" Map <leader> to <space>
let mapleader = " "

" Show icomplete commands and motions in ruler area
set showcmd

set showmode

" Enable auto completion menu after pressing TAB.
set wildmenu

""" SEARCH
set incsearch                   " search while typing
set hlsearch                    " highlight search
set ignorecase                  " ignore case in searches
set smartcase                   " if search contains uppercase letter, use case-sensetive search
set sessionoptions=curdir,buffers,tabpages,help,resize,winsize " restore session

""" LINES
set scrolloff=9                 " scroll if close to the beginning of the file or to the end
set number                      " set lines numbers
set relativenumber              " make numbers relative
set cursorline                  " highlight a line under the cursor

" VIMCRIPT ------------------------------------------------------------------- {{{

" When started as "evim", evim.vim will already have done these settings, bail
" out.
if v:progname =~? "evim"
  finish
endif

" Get the defaults that most users want.
source $VIMRUNTIME/defaults.vim

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
  endif
endif

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
augroup END

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif

" }}}

" HIGHLIGHT ------------------------------------------------------------------- {{{

" Style message area
" Change the color of the message area (area where messages are shown)
highlight MsgArea ctermfg=cyan ctermbg=black guifg=#88C0D0 guibg=#2E3440

" Style the mode message (e.g., -- INSERT --)
highlight ModeMsg ctermfg=green cterm=bold gui=bold guifg=#A3BE8C

" Style the '-- More --' prompt
highlight MoreMsg ctermfg=blue gui=bold guifg=#81A1C1

" Style user prompt questions
highlight Question ctermfg=magenta gui=bold guifg=#B48EAD

" }}}



" PLUGINS --------------------------------------------------------------------- {{{

call plug#begin()
Plug 'tpope/vim-surround'
Plug 'preservim/nerdtree'
call plug#end()

" NERDTree
" Open NERDTree when entering vim
" autocmd VimEnter * NERDTree | wincmd p
" Ctrl+N to toggle NERDTree
map <C-n> :NERDTreeToggle<CR>

" }}}
