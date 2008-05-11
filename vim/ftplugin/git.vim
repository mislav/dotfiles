"=============================================================================
" Copyright:    Copyright © Pierre Habouzit
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               git.vim is provided *as is* and comes with no
"               warranty of any kind, either expressed or implied. In no
"               event will the copyright holder be liable for any damages
"               resulting from the use of this software.
" Description:  git-commit(1) helper
" Maintainer:   Pierre Habouzit <madcoder@debian.org>
" Last Changed: Mon, 26 Nov 2007 10:06:15 +0100
" Usage:        This file should live in your ftplugin directory.
"
"               The configurations variables are:
"
"                 g:git_diff_opts        - options to add to git diff,
"                                          (default "-C -C")
"                 g:git_diff_spawn_mode  - use auto-split on commit ?
"                                          * 1 == hsplit
"                                          * 2 == vsplit
"                                          * none else (default)
"
"               The default keymaping is:
"
"                 <Leader>gd   - view the diff in a hsplit
"                 <Leader>ghd  - view the diff in a hsplit
"                 <Leader>gvd  - view the diff in a vsplit
"========================================================================={{{=

if exists("b:did_ftplugin") | finish | endif

let b:did_ftplugin = 1

setlocal tw=74
setlocal nowarn nowb

function! Git_diff_windows(vertsplit, auto, opts)
    if a:vertsplit
        rightbelow vnew
    else
        rightbelow new
    endif
    silent! setlocal ft=diff previewwindow bufhidden=delete nobackup noswf nobuflisted nowrap buftype=nofile
    exe "normal :r!LANG=C git diff --stat -p --cached ".a:opts."\no\<esc>1GddO\<esc>"
    setlocal nomodifiable
    noremap <buffer> q :bw<cr>
    if a:auto
        redraw!
        wincmd p
        redraw!
    endif
endfunction

noremap <buffer> <Leader>gd :call Git_diff_windows(0, 0)<cr>
noremap <buffer> <Leader>ghd :call Git_diff_windows(0, 0)<cr>
noremap <buffer> <Leader>gvd :call Git_diff_windows(1, 0)<cr>

if !exists("g:git_diff_opts")
    let g:git_diff_opts = "-C -C"
endif
if exists("g:git_diff_spawn_mode")
    if g:git_diff_spawn_mode == 1
        call Git_diff_windows(0, 1, g:git_diff_opts)
    elseif g:git_diff_spawn_mode == 2
        call Git_diff_windows(1, 1, g:git_diff_opts)
    endif
endif

" }}}
