
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

" Plugins from Github, name as it appears in the URL
Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'majutsushi/tagbar'
Plugin 'jlanzarotta/bufexplorer'
Plugin 'kien/ctrlp.vim'
Plugin 'FelikZ/ctrlp-py-matcher'
Plugin 'tpope/vim-sensible'
Plugin 'tacahiroy/ctrlp-funky'
Plugin 'tpope/vim-surround'              " replace pairings ( { [ ' ...
Plugin 'tomtom/tcomment_vim'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'flazz/vim-colorschemes'
Plugin 'python-mode/python-mode'
Plugin 'jmcantrell/vim-diffchanges'
Plugin 'tpope/vim-unimpaired'
Plugin 'w0rp/ale'
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
Plugin 'mattn/emmet-vim'
Plugin 'skywind3000/asyncrun.vim'
Plugin 'rking/ag.vim'
" Plugin 'Yggdroot/indentLine'
" Plugin 'Valloric/YouCompleteMe'

call vundle#end()

" -----------------------------------------------------------------------------

" A function to clear the undo history
function! <SID>clearUndo()
  let old_undolevels = &undolevels
  set undolevels=-1
  exe "normal a \<BS>\<Esc>"
  let &undolevels = old_undolevels
  unlet old_undolevels
endfunction
com! -nargs=0 ClearUndo call <SID>clearUndo()

" -----------------------------------------------

function! <SID>wrapToggle()
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
com! -nargs=0 WrapToggle call <SID>wrapToggle()

" -----------------------------------------------

" Save current view settings on a per-window, per-buffer basis.
function! AutoSaveWinView()
    if !exists("w:SavedBufView")
        let w:SavedBufView = {}
    endif
    let w:SavedBufView[bufnr("%")] = winsaveview()
endfunction

" Restore current view settings.
function! AutoRestoreWinView()
    let buf = bufnr("%")
    if exists("w:SavedBufView") && has_key(w:SavedBufView, buf)
        let v = winsaveview()
        let atStartOfFile = v.lnum == 1 && v.col == 0
        if atStartOfFile && !&diff
            call winrestview(w:SavedBufView[buf])
        endif
        unlet w:SavedBufView[buf]
    endif
endfunction

" When switching buffers, preserve window view.
if v:version >= 700
    autocmd BufLeave * call AutoSaveWinView()
    autocmd BufEnter * call AutoRestoreWinView()
endif

" -----------------------------------------------

let g:quickfix_is_open = 0
function! <SID>quickfixToggle()
  if g:quickfix_is_open
    cclose
    let g:quickfix_is_open = 0
    execute g:quickfix_return_to_window . "wincmd w"
  else
    let g:quickfix_return_to_window = winnr()
    copen
    let g:quickfix_is_open = 1
  endif
endfunction

" -----------------------------------------------

function! <SID>foldColumnToggle()
  if &foldcolumn
     setlocal foldcolumn=0
  else
     setlocal foldcolumn=4
  endif
endfunction

" -----------------------------------------------

function! <SID>agFind()
  let g:quickfix_is_open = 1
  execute 'Ag ' . expand('<cword>')
endfunction

" -----------------------------------------------

" copy current files path to clipboard
com! -nargs=0 CopyPath let @"=expand("%:p")

" sort words in the current line
com! -nargs=0 SortInLine call setline(line('.'),join(sort(split(getline('.'))), ' '))

" com! -nargs=0 Breakpoint normal Oimport pudb; pu.db; # XXX Breakpoint
com! -nargs=0 Breakpoint normal Odebugger; // XXX Breakpoint

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

let g:molokai_original = 1
let g:rehash256 = 1
colorscheme molokai
" setting removing every specific default coloring to fall back to terminal default colors
hi Normal ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
" setting vertical split bar colors
hi VertSplit ctermfg=240 ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
" setting error message highlight color
hi ErrorMsg ctermfg=199 ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE
" setting search highlight color
hi Search ctermfg=7 ctermbg=88 cterm=NONE guifg=NONE guibg=NONE gui=NONE

" set vertical split bar char to space
set fillchars+=vert:\|
" hi OverLength ctermbg=234 ctermfg=NONE guibg=NONE
" match OverLength /\%85v.\+/

set undofile
set undodir=~/.vim/undo
set colorcolumn=80
set cursorline
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

if &term =~ "^xterm\\|rxvt"
  " 1 or 0 -> solid block
  " 2 -> blinking block
  " 3 -> solid underscore
  " 4 -> blinking underscore
  " 5 -> solid vertical bar
  " 6 -> blinking vertical bar
  let &t_SI = "\<Esc>[6 q"        " cursor in insert mode
  let &t_SR = "\<Esc>[4 q"        " cursor in replace mode
  let &t_EI = "\<Esc>[2 q"        " cursor in normal mode
endif

" -----------------------------------------------------------------------------

" General

set shell=/bin/zsh
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
" set paste                       " no intelligent indenting when pasting from clipboard, this breaks gq indenting
set nopaste
set linebreak
set number                      " line numbering
set nolist                      " list disables linebreak
set textwidth=0
set wrapmargin=0
set formatoptions-=t
set formatoptions+=l
set autoread                    " auto reload unchanged files
set autochdir
set tags=./.tags;,~/.tags
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab                   " replace tab with space
set hidden                      " allow switching between unsaved buffers
set noswapfile                  " not a fan of swp files
set ignorecase                  " case insensitive search by default
set list listchars=tab:\❘\ ,trail:·,extends:»,precedes:«,nbsp:×
" set omnifunc=syntaxcomplete#Complete " Enable omnicompletion
" set guifont=Monaco\ for\ Powerline:h13

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

  " For all text files set 'textwidth' to 80 characters.
  autocmd FileType text setlocal textwidth=80

  " Remove trailing whitespaces on write
  autocmd BufWritePre * %s/\s\+$//e

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  " run prettier on js files on write
  autocmd BufWritePost *.js AsyncRun -post=checktime ./node_modules/.bin/eslint --fix %

  augroup END
else
  set autoindent         " always set autoindenting on
endif " has("autocmd")

" -----------------------------------------------------------------------------

" Plugin setup

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
let g:ctrlp_working_path_mode = 'ar'
let g:ctrlp_root_markers = [ '.ctrlp' ]
let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }
if executable('ag')
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  let g:ctrlp_use_caching = 0
endif
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(pyc|pyo|exe|so|dll|la|png|sh|php|pc|0|S|vcproj|mak|sample|po|m4|asm|am|in|Po|lo|d|o|Plo)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

" Ctrlp Funky
let g:ctrlp_funky_syntax_highlight = 1

" Python-mode
let g:pymode = 0                        " disable pymode as it slows down vim
let g:pymode_lint = 0
let g:pymode_lint_ignore = ['W', 'E111', 'E201', 'E202', 'E265', 'E114', 'E302', 'E203', 'E122', 'E124', 'E127', 'E128']
" let g:pymode_warnings = 1
let g:pymode_indent = 0
let g:pymode_folding = 0
let g:pymode_options_colorcolumn = 1
let g:pymode_options_max_line_length = 79
let g:pymode_quickfix_minheight = 3
let g:pymode_quickfix_maxheight = 12
let g:pymode_breakpoint_bind = '<leader>b'
let g:pymode_doc = 0
let g:pymode_lint_checkers = ['pep8']
let g:pymode_rope = 0
let g:pymode_rope_rename_bind = '<leader>g'
let g:pymode_rope_completion = 0
let g:pymode_run = 0
let g:pymode_run_bind = '<leader>R'
let g:pymode_breakpoint = 1
let g:pymode_breakpoint_cmd = 'import pdb; pdb.set_trace(); # XXX Breakpoint'
" let g:pymode_breakpoint_cmd = 'import rpdb; __dbg = rpdb.Rpdb(port=12345); __dbg.set_trace(); # XXX Breakpoint'
" let g:pymode_breakpoint_cmd = 'import pudb; pu.db; # XXX Breakpoint'
let g:pymode_syntax = 0

" Airline
let g:airline_theme = 'minimalist'
let g:airline#extensions#tagbar#flags = 'f'  " show full tag hierarchy

" Netrw
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_winsize = 25
let g:netrw_altv = 1

" bufExplorer
let g:bufExplorerShowNoName = 1

"indentLine
let g:indentLine_color_term = 239
let g:indentLine_char = '¦'

let g:ale_sign_error = '>>' " Less aggressive than the default '>>'
let g:ale_sign_warning = '.'
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 0
let errorformat =
        \ '%f:%l:%c: %trror: %m,' .
        \ '%f:%l:%c: %tarning: %m,' .
        \ '%f:%l:%c: %tote: %m'

let g:user_emmet_leader_key='<Tab>'
let g:user_emmet_settings = {
  \  'javascript.jsx' : {
    \      'extends' : 'jsx',
    \  },
  \}

" The Silver Searcher
let g:ag_working_path_mode="r"
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
  set grepformat=%f:%l:%C:%m
endif

" -----------------------------------------------------------------------------

" Key combinations

let mapleader = ";"

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

nnoremap <leader>b :Breakpoint<Cr>

" ctag search with CtrlP
nnoremap <leader>i :CtrlPTag<Cr>
nnoremap <leader>f :BufExplorer<Cr>
" quick save
nnoremap <Leader>s :update<Cr>
" quick close current buffer without closing window
nnoremap <leader>d :bp<bar>sp<bar>bn<bar>bd<CR>

" switch to the alternative buffer
nnoremap <Leader>t :b#<Cr>
nnoremap <Leader>o :CtrlPFunky<Cr>
" narrow the list down with a word under cursor
nnoremap <Leader>O :execute 'CtrlPFunky ' . expand('<cword>')<Cr>

" clear search highlightings when done
nnoremap <Leader>c :nohlsearch<Cr>

noremap  <Leader>w :WrapToggle<CR>
nnoremap <Leader>u :ClearUndo<Cr>

" make table
nnoremap <Leader>T :%!column -t<Cr>
vnoremap <Leader>T :%!column -t<Cr>

" reload vimrc
nnoremap <Leader>r :so $MYVIMRC<Cr>

noremap <Leader>x :Vexplore<CR>

noremap <F8> :TagbarToggle<CR>

noremap <Leader>j :join<CR>

" moving between windows
noremap <C-k> <C-w>k
noremap <C-j> <C-w>j
noremap     <C-w>h
noremap <C-l> <C-w>l

" split
nnoremap <C-w>o :split<Cr>
nnoremap <C-w>e :vsplit<Cr>

" resize window
" nnoremap     :vertical resize -1<CR>
" nnoremap <C-j> :resize +1<CR>
" nnoremap <C-k> :resize -1<CR>
" nnoremap <C-l> :vertical resize +1<CR>

" scrolling with arrow keys as well
nnoremap <C-Up> <C-y>
nnoremap <C-Down> <C-e>
nnoremap <S-k> <C-y>k
nnoremap <S-j> <C-e>j

" moving lines
" nnoremap <C-S-j> :m .+1<CR>==
" nnoremap <C-S-k> :m .-2<CR>==
" vnoremap <C-S-j> :m '>+1<CR>gv=gv
" vnoremap <C-S-k> :m '<-2<CR>gv=gv

" jumping to lables
nnoremap gL :lprev<Cr>
vnoremap gL :lprev<Cr>
nnoremap gl :lnext<Cr>
vnoremap gl :lnext<Cr>

nnoremap Y yg_
nnoremap <C-p> yyp
vnoremap <C-p> ygv<Esc>p

" Don't use Ex mode, use Q for formatting
noremap Q gq

nnoremap * *<C-o>:%s///gn<CR>``

noremap <Leader>q :call <SID>quickfixToggle()<Cr>
nnoremap <leader>F :call <SID>foldColumnToggle()<Cr>
nnoremap <leader>D :DiffChangesDiffToggle<Cr>

" copy current files path to clipboard
nmap <Leader>cp :CopyPath<CR>

" toggle line number
nnoremap <leader>n :setlocal number!<cr>

" to avoid vim cleaning up indentations on escape
inoremap <CR> <CR>x<BS>
nnoremap o ox<BS>
nnoremap O Ox<BS>

noremap <Leader>vv :call <SID>agFind()<Cr>

" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

command! PrettyPrintJSON %!python -m json.tool
command! PrettyPrintHTML !tidy -mi -html -wrap 0 %
command! PrettyPrintXML !tidy -mi -xml -wrap 0 %

map <leader>a :ALELint<CR>

" -----------------------------------------------------------------------------

