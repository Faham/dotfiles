" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2011 Apr 15
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

"enable confirmation question for unsaved buffers on exit"
set confirm

"autosave current session on exit"
au VimLeavePre * if v:this_session != '' | exec "mks! " . v:this_session | endif

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set backupdir=~/.vim/tmp
set directory^=~/.vim/tmp
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" line numbering
set number

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
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

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" A function to clear the undo history
function! <SID>ForgetUndo()
    let old_undolevels = &undolevels
    set undolevels=-1
    exe "normal a \<BS>\<Esc>"
    let &undolevels = old_undolevels
    unlet old_undolevels
endfunction
command! -nargs=0 ClearUndo call <SID>ForgetUndo()

function! Incr()
  let a = line('.') - line("'<")
  let c = virtcol("'<")
  if a > 0
    execute 'normal! '.c.'|'.a."\<C-a>"
  endif
  normal `<
endfunction
vnoremap <Leader>a :call Incr()<CR>

execute pathogen#infect()

" set colorcolumn=80
" highlight ColorColumn ctermbg=darkgray

" to disable the annoying beeps
set visualbell
set vb t_vb=

set nowrap
set paste " no intelligent indenting when pasting from clipboard
set linebreak
set nolist  " list disables linebreak
set textwidth=0
set wrapmargin=0
set formatoptions-=t
set formatoptions+=l
set autoread " auto reload unchanged files
set autochdir

set tags=./tags,$GST_HOME/tags
set tabstop=3
set softtabstop=3
set shiftwidth=3
set expandtab     " replace tab with space
set hidden        " allow switching between unsaved buffers
set list listchars=tab:\❘\ ,trail:·,extends:»,precedes:«,nbsp:×

" Status line
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
hi StatusLine ctermbg=black ctermfg=white

let g:multi_cursor_exit_from_insert_mode = 0 " don't clear multi-cursors when escape

" ctrlp setup
let g:ctrlp_map = '<Leader>p'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_match_window_bottom=1
let g:ctrlp_max_files=0
let g:ctrlp_max_height=25
let g:ctrlp_match_window_reversed=0
let g:ctrlp_mruf_max=500
let g:ctrlp_follow_symlinks=1
let g:ctrlp_clear_cache_on_exit=0
let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_root_markers = ['.ctrlp']
if executable('ag')
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif
nnoremap <c-i> :CtrlPTag<cr>

" let g:ctrlp_custom_ignore = {
"   \ 'dir':  '\v[\/]\.(git|hg|svn)$',
"   \ 'file': '\v\.(exe|so|dll)$',
"   \ 'link': 'some_bad_symbolic_links',
"   \ }

" for gstreamer
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.git$|\.deps|\.libs',
  \ 'file': '\v\.(la|png|sh|php|pc|0|S|vcproj|txt|mak|sample|po|m4|asm|am|in|Po|lo|d|o|Plo)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

let mapleader = ";"

nnoremap <Leader>f :BufExplorer<Cr>
" quick save
nnoremap <Leader>s :update<Cr>
" quick close current buffer
nnoremap <Leader>d :bd<Cr>
" switch to the alternative buffer
nnoremap <Leader>t :b#<Cr>
nnoremap <Leader>o :CtrlPFunky<Cr>
" narrow the list down with a word under cursor
nnoremap <Leader>fU :execute 'CtrlPFunky ' . expand('<cword>')<Cr>

" clear search highlightings when done
nnoremap <Leader>c :let @/ = ""<Cr>

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
" nnoremap <C-j> :m .+1<CR>==
" nnoremap <C-k> :m .-2<CR>==
" inoremap <C-j> <Esc>:m .+1<CR>==gi
" inoremap <C-k> <Esc>:m .-2<CR>==gi
" vnoremap <C-j> :m '>+1<CR>gv=gv
" vnoremap <C-k> :m '<-2<CR>gv=gv

" for toggelWrap
noremap <silent> <Leader>w :call ToggleWrap()<CR>
function ToggleWrap()
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
    noremap  <buffer> <silent> k   gk
    noremap  <buffer> <silent> j   gj
    noremap  <buffer> <silent> 0   g0
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

"nnoremap xx yydd<CR>
"vnoremap xx yydd<CR>
"nnoremap X y$d$<CR>
"vnoremap X y$d$<CR>
"nnoremap d "_d
"vnoremap d "_d
"nnoremap D "_D
"vnoremap D "_D
"nnoremap c "_c
"vnoremap c "_c
"nnoremap C "_C
"vnoremap C "_C
"nnoremap s "_s
"vnoremap s "_s
"vnoremap i "_s
"nnoremap S "_S
"vnoremap S "_S
"xnoremap p pgvy

