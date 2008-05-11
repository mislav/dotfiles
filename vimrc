" Mislav's .vimrc
" 
" Thank you evil.che.lu (http://evilchelu.googlecode.com/svn/dotfiles/vim/.vimrc)

set nocompatible		         " the past is better left in the past
set encoding=utf-8 nobomb    " BOM often causes trouble
set noautochdir
set sessionoptions=folds,sesdir,tabpages,winsize
set expandtab shiftwidth=2 tabstop=2  " Ruby and JavaScript made me do it!
set noerrorbells
set visualbell               " must turn visual bell on to remove audio bell
" set t_vb=                  " turn bells of, must also set this in .gvimrc

"""""""""" visual
syntax on
set laststatus=2              " always show status line
set scrolloff=2               " minlines to show around cursor
set sidescrolloff=4           " minchars to show around cursor
set linebreak                 " when wrapping, try to break at characters in breakat
set breakat=\ ^I!@*-+;:,./?   " when wrapping, break at these characters
set showbreak=>               " character to show that a line is wrapped
" let loaded_matchparen = 1     " don't show matching brace when moving around, it's too slow

set gdefault                 " global search/replace by default
set ignorecase               " ignore case when searching
set smartcase                " override ignorecase when there are uppercase characters
set incsearch hlsearch       " highlight search matches
nmap <silent> <C-H> :silent noh<CR>
set showmatch			           " when inserting a bracked briefly flash its match

set showcmd					         " display an incomplete command (lower right corner)
" set wildmenu                 " nice menu when completing commands
" set wildmode=list:longest,full

if has("gui_running")
	set gfn=Inconsolata\ 12
	set linespace=1
	set guioptions=tmaegr      " menu, tearoffs, autoselect, tabline etc.
  " set guioptions=ceimMgrb       " aA BAD?
	colorscheme oceandeep
elseif &t_Co > 2
	colorscheme slate
endif

set switchbuf=usetab
" set tabpagemax=100
" splitting a window will reduce the size of the current window and leave the other windows the same:
" set noequalalways 
" set guiheadroom=0
" set hidden
set splitbelow
" set browsedir=buffer

" splits to the right (vertically) from file browser
let g:netrw_altv = 1

" Minibuffer Explorer Settings
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplModSelTarget = 1

set ai	  						" Turn on autoindenting
set aw		  					" Save file when compiling, etc.
set autoread
set nobackup					" Don't create backup files
set backspace=indent,eol,start  " backspace over anything
set textwidth=0
"set viminfo='20,\"50		" Read/write a .viminfo file, don't store more than 50 lines of registers
"set whichwrap=b,s,<,>,[,]	" End of line cursor support
set ruler
"set comments=sl:/**,mb:\ *,exl:\ */,sr:/*,mb:*,exl:*/,://

" pasting to windows apps doesn't require prefixing "*
" set clipboard=unnamed
" FIXME: don't like! how to turn off autocopy when selecting in visual mode?? (see guioptions)

" load filetype file + plugin + indent files
filetype plugin indent on

" When starting to edit a file (watch the sequence!):
"   Java, C, C++ : formatting of comments; C-indenting on
"   other files : switch it off
autocmd BufRead * set formatoptions=tcql nocindent comments&
autocmd BufRead *.java,*.c,*.h,*.cc set formatoptions=tcroq cindent comments=sr:/**,mb:*,elx:*/,sr:/*,mb:*,elx:*/,://
"autocmd BufRead *.rb,*.rbx,*.gem,*.gemspec,[rR]antfile,*.rant,[rR]akefile* set formatoptions=tcoq expandtab shiftwidth=2 tabstop=2

au! BufRead,BufNewFile *.sass setfiletype sass 
au! BufRead,BufNewFile *.haml setfiletype haml 
au BufRead,BufNewFile COMMIT_EDITMSG setf git

" never see ^M again! (DOS text files)
autocmd BufRead * silent! %s/^M$//
" alternative = :set ff=dos (:help ff for info)

" Shift-Enter inserts 'end' for ruby scripts
" Copyright (C) 2005-2007 pmade inc. (Peter Jones pjones@pmade.com)
function PMADE_RubyEndToken ()
    let current_line = getline('.')
    let braces_at_end = '{\s*\(|\(,\|\s\|\w\)*|\s*\)\?\(\s*#.*\)\?$'
    let stuff_without_do = '^\s*\<\(class\|if\|unless\|begin\|case\|for\|module\|while\|until\|def\)\>'
    let with_do = '\<do\>\s*\(|\(,\|\s\|\w\)*|\s*\)\?\(\s*#.*\)\?$'

    if getpos('.')[2] < len(current_line)
        return "\<CR>"
    elseif match(current_line, braces_at_end) >= 0
        return "\<CR>}\<C-O>O"
    elseif match(current_line, stuff_without_do) >= 0
        return "\<CR>end\<C-O>O"
    elseif match(current_line, with_do) >= 0
        return "\<CR>end\<C-O>O"
    else
        return "\<CR>"
    endif
endfunction

function UseRubyIndent ()
    setlocal tabstop=2
    setlocal softtabstop=2
    setlocal shiftwidth=2
    setlocal expandtab

    imap <buffer> <CR> <C-R>=PMADE_RubyEndToken()<CR>
endfunction

autocmd FileType ruby,eruby call UseRubyIndent()

" the evilchelu hack!
inoremap <ESC> <space><BS><ESC>

" Format the current paragraph according to
" the current 'textwidth' with CTRL-J:
nmap <C-J>      gqap
vmap <C-J>      gq
imap <C-J>      <C-O>gqap

" do formatting - Q otherwise starts Ex mode
" map Q gq

" Delete line with CTRL-K
map  <C-K>      dd
imap <C-K>      <C-O>dd

" omni autocomplete in insert mode:
imap <C-SPACE>	<C-X><C-O>

" CTRL-C and CTRL-Insert are Copy
vnoremap <C-C> "+y
" vnoremap <C-Insert> "+y

" CTRL-V and SHIFT-Insert are Paste
" map <C-V>		"+gP
map <S-Insert>		"+gP
cmap <S-Insert>		<C-R>+

" Use CTRL-S for saving, also in Insert mode
noremap <C-S>		:update<CR>
vnoremap <C-S>	<C-C>:update<CR>
inoremap <C-S>	<C-O>:update<CR>

" CTRL-A is Select all
noremap <C-A> gggH<C-O>G
inoremap <C-A> <C-O>gg<C-O>gH<C-O>G
cnoremap <C-A> <C-C>gggH<C-O>G
onoremap <C-A> <C-C>gggH<C-O>G
snoremap <C-A> <C-C>gggH<C-O>G
xnoremap <C-A> <C-C>ggVG

" CTRL-F4 is Close window
noremap <C-F4> <C-W>c
inoremap <C-F4> <C-O><C-W>c
cnoremap <C-F4> <C-C><C-W>c
onoremap <C-F4> <C-C><C-W>c

" move a window to a new tab
" map <C-T> <C-W>T

" helpful mappings for using twitter.vim
" see http://vim.sourceforge.net/scripts/script.php?script_id=1853
let g:twitterusername='mislav'
let g:twitterpassword=''

map <unique> <Leader>tp <Esc>:let g:twitterpassword=inputsecret('password? ')<CR>
map <unique> <Leader>tw <Esc>:execute 'TwitterStatusUpdate ' . inputdialog('Enter a Twitter status message:')<CR>
map <unique> <Leader>tf <Esc>:TwitterFriendsTimeline<CR>
