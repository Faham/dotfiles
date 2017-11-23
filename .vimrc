
" -----------------------------------------------------------------------------

if v:progname =~? "evim"
  finish
endif

" Bail out if something that ran earlier, e.g. a system wide vimrc, does not
" want Vim to use these default values.
if exists('skip_defaults_vim')
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
" Avoid side effects when it was already reset.
if &compatible
  set nocompatible
endif

" When the +eval feature is missing, the set command above will be skipped.
" Use a trick to reset compatible only when the +eval feature is missing.
silent! while 0
  set nocompatible
silent! endwhile

filetype off

" -----------------------------------------------------------------------------

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'jlanzarotta/bufexplorer'
Plugin 'kien/ctrlp.vim'
Plugin 'FelikZ/ctrlp-py-matcher'
Plugin 'tpope/vim-sensible'
Plugin 'tacahiroy/ctrlp-funky'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-surround'              " replace pairings ( { [ ' ...
Plugin 'tomtom/tcomment_vim'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'flazz/vim-colorschemes'

call vundle#end()

" -----------------------------------------------------------------------------

" A function to clear the undo history
function! <SID>ForgetUndo()
    let old_undolevels = &undolevels
    set undolevels=-1
    exe "normal a \<BS>\<Esc>"
    let &undolevels = old_undolevels
    unlet old_undolevels
endfunction
command! -nargs=0 ClearUndo call <SID>ForgetUndo()

" -----------------------------------------------

function! ToggleWrapFunc()
  if &wrap
    echo "Wrap OFF"
    setlocal nowrap
    set virtualedit=all
    silent! nunmap <buffer> <Up>
    silent! nunmap <buffer> <Down>
    silent! nunmap <buffer> <Home>
    silent! nunmap <buffer> <End>
    silent! iunmap <buffer> <Up>
    silent! iunmap <buffer> <Down>
    silent! iunmap <buffer> <Home>
    silent! iunmap <buffer> <End>
  else
    echo "Wrap ON"
    setlocal wrap linebreak nolist
    set virtualedit=
    setlocal display+=lastline
    noremap  <buffer> <silent> 0   g0
    noremap  <buffer> <silent> k   gk
    noremap  <buffer> <silent> j   gj
    noremap  <buffer> <silent> $   g$
    noremap  <buffer> <silent> <Up>   gk
    noremap  <buffer> <silent> <Down> gj
    noremap  <buffer> <silent> <Home> g<Home>
    noremap  <buffer> <silent> <End>  g<End>
    inoremap <buffer> <silent> <Up>   <C-o>gk
    inoremap <buffer> <silent> <Down> <C-o>gj
    inoremap <buffer> <silent> <Home> <C-o>g<Home>
    inoremap <buffer> <silent> <End>  <C-o>g<End>
  endif
endfunction
command! -nargs=0 ToggleWrap call ToggleWrapFunc()

" -----------------------------------------------------------------------------

" Theme setup

" Switch syntax highlighting on when the terminal has colors or when using the
" GUI (which always has colors).
if &t_Co > 2 || has("gui_running")
  syntax on

  " I like highlighting strings inside C comments.
  " Revert with ":unlet c_comment_strings".
  let c_comment_strings=1
  set hlsearch
endif

let g:airline_theme = 'minimalist'
let g:molokai_original = 1
let g:rehash256 = 1

colorscheme molokai

set laststatus=2
set statusline=%t       "tail of the filename
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
set statusline+=%{&ff}] "file format
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag
set statusline+=%y      "filetype
set statusline+=%=      "left/right separator
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
set colorcolumn=80
set cursorline

" change cursor shape in different modes
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"

hi OverLength ctermbg=black ctermfg=NONE guibg=NONE
match OverLength /\%80v.\+/

hi Normal ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE

" -----------------------------------------------------------------------------

" General

set confirm                     " Ask to save before exit if needed
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
set backupdir=~/.vim/tmp//
set directory^=~/.vim/tmp//
set history=200                 " keep 50 lines of command line history
set ruler                       " show the cursor position all the time
set showcmd                     " display incomplete commands
set wildmenu                    " display completion matches in a status line
set ttimeout                    " time out for key codes
set ttimeoutlen=100             " wait up to 100ms after Esc for special key
set scrolloff=5                 " Show a few lines of context around the cursor.
set visualbell                  " to disable the annoying beeps
set vb t_vb=
set nowrap
set paste                       " no intelligent indenting when pasting from clipboard
set linebreak
set number                      " line numbering
set nolist                      " list disables linebreak
set textwidth=0
set wrapmargin=0
set formatoptions-=t
set formatoptions+=l
set autoread                    " auto reload unchanged files
set autochdir
set tags=./.tags,~/.tags
set tabstop=3
set softtabstop=3
set shiftwidth=3
set expandtab                   " replace tab with space
set hidden                      " allow switching between unsaved buffers
set list listchars=tab:\❘\ ,trail:·,extends:»,precedes:«,nbsp:×
" set omnifunc=syntaxcomplete#Complete " Enable omnicompletion
" set guifont=Monaco\ for\ Powerline:h13

" Don't use Ex mode, use Q for formatting
map Q gq

let g:multi_cursor_exit_from_insert_mode = 0 " don't clear multi-cursors when escape

"autosave current session on exit"
au VimLeavePre * if v:this_session != '' | exec "mks! " . v:this_session | endif

" Do incremental searching when it's possible to timeout.
if has('reltime')
  set incsearch
endif

if has("vms")
  set nobackup                  " do not keep a backup file, use versions instead
else
  set backup                    " keep a backup file
endif

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
if has('win32')
  set guioptions-=t
endif

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

if has('langmap') && exists('+langremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping.  If set (default), this may break plugins (but it's backward
  " compatible).
  set nolangremap
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END
else
  set autoindent         " always set autoindenting on
endif " has("autocmd")

" -----------------------------------------------------------------------------

" Ctrlp setup
let g:ctrlp_map = '<Leader>p'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_match_window_bottom=1
let g:ctrlp_max_height=25
let g:ctrlp_max_files=0
let g:ctrlp_match_window_reversed=0
let g:ctrlp_mruf_max=500
let g:ctrlp_follow_symlinks=1
let g:ctrlp_clear_cache_on_exit=0
let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_root_markers = ['.ctrlp']
let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
if executable('ag')
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(pyc|pyo|exe|so|dll|la|png|sh|php|pc|0|S|vcproj|txt|mak|sample|po|m4|asm|am|in|Po|lo|d|o|Plo)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

" -----------------------------------------------------------------------------

" Key combinations

let mapleader = ";"

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" ctag search with CtrlP
nnoremap <leader>i :CtrlPTag<cr>
nnoremap <Leader>f :BufExplorer<Cr>
" quick save
nnoremap <Leader>s :update<Cr>
" quick close current buffer
nnoremap <Leader>d :bd<Cr>
" switch to the alternative buffer
nnoremap <Leader>t :b#<Cr>
nnoremap <Leader>o :CtrlPFunky<Cr>
" narrow the list down with a word under cursor
" nnoremap <Leader>fU :execute 'CtrlPFunky ' . expand('<cword>')<Cr>

" clear search highlightings when done
nnoremap <Leader>c :let @/ = ""<Cr>

noremap  <Leader>w :ToggleWrap<CR>
nnoremap <Leader>u :ClearUndo<Cr>
nnoremap <Leader>n :NERDTreeToggle<CR>

" make table
nnoremap <Leader>T :%!column -t<Cr>
vnoremap <Leader>T :'<,'>%!column -t<Cr>

" sort
nnoremap <Leader>S :%!sort -k1<Cr>
vnoremap <Leader>S :'<,'>%!sort -k1<Cr>

" reload vimrc
nnoremap <Leader>r :so $MYVIMRC<Cr>

nnoremap <Leader>x :Explore<CR>
vnoremap <Leader>x :Explore<CR>

" working with tabs
nnoremap <F7> :bn<CR>==
vnoremap <F7> :bn<CR>==
nnoremap <F8> :bp<CR>==
vnoremap <F8> :bp<CR>==

" working with tabs
nnoremap <S-F7> :tabn<CR>==
vnoremap <S-F7> :tabn<CR>==
nnoremap <S-F8> :tabp<CR>==
vnoremap <S-F8> :tabp<CR>==

" moving lines
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
" inoremap <C-j> <Esc>:m .+1<CR>==gi
" inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" noremap! <C-Y> <Esc>klyWjpa

" scrolling
" nnoremap <silent> <C-Up> <C-y><CR>
" nnoremap <silent> <C-Down> <C-e><CR>
" vnoremap <silent> <C-Up> <C-y><CR>
" vnoremap <silent> <C-Down> <C-e><CR>

" -----------------------------------------------------------------------------

