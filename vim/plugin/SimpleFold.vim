" Copyright (C) 2006-2007    Mauricio Fernandez <mfp@acm.org>
" Plugin for simple search-based folding
" Ships with support for Ruby, Perl, Java, PHP, Objective Caml, but can be
" easily tailored to other filetypes.
"     Version:    0.5.1 <preliminary>
"      Author:    Mauricio Fernandez <mfp@acm.org>
"  Maintainer:    Mauricio Fernandez <mfp@acm.org> http://eigenclass.org
"     License:    GPL
"
" Changelog
" ---------
" 0.5.0 (tested on vim 7.0)
"  * changed configuration system: use g:xxx_simplefold_* variables instead of
"    autocmd (you can also use w:xxx_simplefold_* or b:xxx_simplefold_* for
"    window/buffer-specific settings)
"  * added Perl, PHP, Objective Caml support
" 
" Mappings and commands
" ---------------------
" Defines the :Fold command; use it as 
"   :Fold \v^function
" You can try it with this very file to see what happens (note that the fold
" corresponding to the current cursor position is left open).
" The default mapping to fold the current file using the default fold
" expression (more on this below) is
"    map <unique> <silent> <Leader>f <Plug>SimpleFold_Foldsearch
"                          =========
" i.e. \f unless you changed mapleader. You can copy the above mapping to your
" .vimrc and modify it as desired.
"
" Options
" -------
" By default, secondary, nestable subfolds will be created for the supported
" filetypes (read below to see how this is controlled by the associated fold
" expressions). You can turn that off with:
"   let g:SimpleFold_use_subfolds = 0
"
" Fold expressions
" ----------------
" The default fold expression for most filetypes is
"   let g:simplefold_expr = '\v^\s*[#%"0-9]{0,4}\s*\{(\{\{|!!)'
" The expressions for the extra marker-based folding phase are:
"   let g:simplefold_marker_start = '\v\{\{\{\{'
"   let g:simplefold_marker_end = '\v\}\}\}\}'
"
" You can tailor the fold expressions to other filetypes by defining variables
" named after the filetype (scroll to the bottom of this file for further,
" actual examples):
"
" " folds start with the xxx_simplefold_expr; a line matching this expression
" " marks the end of the previous fold (if any) and the start of a new one
"    let g:ruby_simplefold_expr = 
"	    \'\v(^\s*(def|class|module|attr_reader|attr_accessor|alias_method|' .
"                 \   'attr|module_function' . ')\s' . 
"           \ '\v^\s*(public|private|protected)>' .
"	    \ '|^\s*\w+attr_(reader|accessor)\s|^\s*[#%"0-9]{0,4}\s*\{\{\{[^{])' .
"	    \ '|^\s*[A-Z]\w+\s*\=[^=]'
"
" g:xxx_simplefold_end_expr (not used in the default definitions in this file)
" can be used to mark the end of a fold without starting a new one (leaving
" all the lines between the end of the fold and the start of the next one
" unfolded).
"
" " once a line matches xxx_simplefold_expr, lines immediately before it
" " matching the following expression are also included in the fold (but not
" " shown when the fold is closed). Useful to place comments in the same fold as 
" " the definition they apply to
"    let g:ruby_simplefold_prefix = '\v^\s*(#([^{]+|\{[^{]|\{\{[^{])*)?$'
"
" " xxx_simplefold_nestable_{start,end}_expr define nestable folds (always
" " inside a top-level fold)
"
"    let g:ruby_simplefold_nestable_start_expr = 
"		\ '\v^\s*(def>|if>|unless>|while>.*(<do>)?|' . 
"                \         'until>.*(<do>)?|case>|for>|begin>)' .
"                \ '|^[^#]*.*<do>\s*(\|.*\|)?'
"    let g:ruby_simplefold_nestable_end_expr = 
"		\ '\v^\s*end'
"
" Here's the (simpler) setup for Java:
" Java support
"    let g:java_simplefold_expr = 
"			 \ '\(^\s*\(\(private\|public\|protected\|class\)\>\)\)'
"

if exists("loaded_simplefold")
    finish
endif
let loaded_simplefold = 1

let s:save_cpo = &cpo
set cpo&vim

"{{{ set s:sid

map <SID>xx <SID>xx
let s:sid = maparg("<SID>xx")
unmap <SID>xx
let s:sid = substitute(s:sid, 'xx', '', '')

"{{{ s:GetOption
" grab a user-specified option to override the default provided.  options are
" searched in the window, buffer, then global spaces.
function! s:GetOption(name, ...)
    if exists("w:{&filetype}_" . a:name)
	execute "return w:{&filetype}_".a:name
    elseif exists("w:" . a:name)
	execute "return w:".a:name
    elseif exists("b:{&filetype}_" . a:name)
	execute "return b:{&filetype}_".a:name
    elseif exists("b:" . a:name)
	execute "return b:".a:name
    elseif exists("g:{&filetype}_" . a:name)
	execute "return g:{&filetype}_".a:name
    elseif exists("g:" . a:name)
	execute "return g:".a:name
    else
	return a:1
    endif
endfunction

function! s:IsOptionSet(name)
    let bogus_val = "df hdsoi3y98 hjsdfhdkj"
    return s:GetOption(a:name, bogus_val) == bogus_val ? 0 : 1
endfunction

"{{{ FoldText
function! s:Num2S(num, len)
    let filler = "                                                            "
    let text = '' . a:num
    return strpart(filler, 1, a:len - strlen(text)) . text
endfunction

function! s:SimpleFold_FoldText()
    let linenum = v:foldstart
    if match(getline(linenum), s:GetOption("simplefold_marker_start")) != -1
	let line = getline(linenum)
    else
	while linenum <= v:foldend
	    let line = getline(linenum)
	    if !s:IsOptionSet("simplefold_prefix") || 
			\ match(line, s:GetOption("simplefold_prefix")) == -1
		break
	    else
		let linenum = linenum + 1
	    endif
	endwhile
	if IsOptionSet("simplefold_prefix") && 
		    \ match(line, s:GetOption("simplefold_prefix")) != -1
	    " all lines matched the prefix regexp
	    let line = getline(v:foldstart)
	endif
    endif
    let sub = substitute(line, '/\*\|\*/\|{{{\d\=', '', 'g')
    let diff = v:foldend - v:foldstart + 1
    return  '+' . v:folddashes . '[' . s:Num2S(diff,3) . ']' . sub
endfunction

"{{{~ Foldsearch originally based on t77: Fold on search result

" Returns -1 if no match, 1 if fold start, 2 if fold end.
function! s:search_boundary(fold_start_re, combined_re, use_combined, flags)
    let saved_cursor_pos = getpos(".")
    "echo "SEARCH BOUNDARY at "
    "echo saved_cursor_pos
    "echo "COMBINED: " . a:combined_re
    if a:use_combined
	"echo "combined search"
	let matched = search(a:combined_re, a:flags)
	if matched < 0
	    "echo "NO MATCH"
	    return -1
	endif
	let cursor_pos = getpos(".")
	let line1 = line(".")               " line where combined RE matched
	"echo "MATCH at " . getline(".")
	call setpos('.', saved_cursor_pos)
	let matched = search(a:fold_start_re, a:flags)
	if matched < 0
	    " no match for fold start RE, was end of fold
	    call setpos('.', cursor_pos)
	    return 2
	end
	"echo "MATCH' at " . getline(".")
	let line2 = line(".")               " line where fold start RE matches
	" determine which part matched, the fold start RE or the fold end RE
	if line1 < line2
	    " the end of fold RE
	    call setpos('.', cursor_pos)
	    "echo "was END OF FOLD"
	    return 2
	else " the fold start RE
	    "echo "was START OF FOLD"
	    "echo getpos(".")
	    return 1
	end
    else
	"echo "simple search (start only)"
	let matched = search(a:fold_start_re, a:flags)
	if matched < 0
	    "echo "NO MATCH"
	    return -1
	else
	    "echo "MATCH at " . getline(".")
	    return 1
	end
    end
endfunction

function! s:Foldsearch(search)
    " set manual
    setlocal fdm=manual
    let orig_cursor_pos = getpos(".")
    normal zE
    normal G$
    " set the foldtext
    execute 'setlocal foldtext=' .  s:sid . 'SimpleFold_FoldText()'
    let folded = 0     "flag to set when a fold is found
    let line1 =  0     "set marker for beginning of fold
    let flags = "w"    "allow wrapping
    let first_code_line = 0
    if a:search == ""
	if s:IsOptionSet("simplefold_expr")
	    let searchre = s:GetOption("simplefold_expr")
	else
	    let searchre = '\v^\s*[#%"0-9]{0,4}\s*\{(\{\{|!!)'
	endif
    else
	let searchre = a:search
    endif
    " combined_re is  fold_start_re | fold_end_re
    if a:search == "" && s:IsOptionSet("simplefold_end_expr")
	let combined_re = '\v(\m' . searchre . '\v)|(\m' . s:GetOption("simplefold_end_expr") . '\v\zs)'
    else
	let combined_re = searchre
    endif
    let in_fold = 0
    let first_fold = 1
    let prev_cpos = getpos(".")
    while 1
	let boundary_match = s:search_boundary(searchre, combined_re, in_fold, flags)
	let cpos = getpos(".")
	if boundary_match < 0 || cpos == prev_cpos
	    break
	end
	let set_in_fold_to = 0
	let  line2 = line(".")
	if boundary_match == 1 " start of fold, end of prev one
	    "echo "start of fold boundary"
	    let next_re = combined_re
	    while line2 - 1 >= line1 && line2 - 1 > 0 "sanity check
		let prevline = getline(line2 - 1)
		if s:IsOptionSet("simplefold_prefix") && 
			    \ (match(prevline, s:GetOption("simplefold_prefix")) != -1)
		    let line2 = line2 - 1
		else
		    break
		endif
	    endwhile
	    let set_in_fold_to = 1
	else " was the end of the fold as found by the end of fold RE component of combined_re
	    let set_in_fold_to = 0
	end
	if (in_fold || first_fold) && (line2 - 1 >= line1)
	    execute ":" . line1 . "," . (line2-1) . "fold"
	    "echo "fold " . line1 . " - " . (line2 - 1)
	    if s:GetOption("SimpleFold_use_subfolds")
		call s:FoldNestableBlocks(first_code_line + 1, line2 - 2, "", "")
	    endif
	    let folded = 1       "at least one fold has been found
	endif
	let line1 = line2     "update marker
	let first_code_line = line2 + 1
	let flags = "W"       "turn off wrapping
	"echo "setting in_fold to " . set_in_fold_to
	let in_fold = set_in_fold_to
	let first_fold = 0
	let prev_cpos = cpos
    endwhile

    let line2 = line("$")
    if (line2  >= line1 && folded == 1)
	execute ":". line1 . "," . line2 . "fold"
	execute "normal " . line1 . "G"
	" try to find the last top-level fold so that we get the correct range
	" for nested subblocks
	if search(searchre, "W") > 0  
	    let line1 = line(".")    
	endif
	let line1 = line1 + 1
	"echo "last call: " line1 . " - " . line2
	if s:GetOption("SimpleFold_use_subfolds")
	    call s:FoldNestableBlocks(line1, line2, "", "")
	endif
    endif
    call s:FoldNestableBlocks(1, line("$"), 
		\ s:GetOption("simplefold_marker_start"), 
		\ s:GetOption("simplefold_marker_end"))
    call setpos(".", orig_cursor_pos)
    silent! normal zMzO
endfunction

function! s:FoldNestableBlocks(start, end, start_expr, end_expr)
    if a:end - a:start < 1
	return 0
    endif

    if a:start_expr == ""
	if s:IsOptionSet("simplefold_nestable_start_expr")
	    let start_expr = s:GetOption("simplefold_nestable_start_expr")
	else
	    return
	endif
    else
	let start_expr = a:start_expr
    endif
    if a:end_expr == ""
	if s:IsOptionSet("simplefold_nestable_end_expr")
	    let end_expr = s:GetOption("simplefold_nestable_end_expr")
	else
	    return
	endif
    else
        let end_expr = a:end_expr
    endif
    "echo "nested " . a:start . " <-> " . a:end
    let origlineno = line(".")
    execute "normal " . (a:start - 1). "G" 
    normal $
    normal zR
    " allow wrapping if a:start was 1 (i.e. we moved to line("$"))
    let flags = (a:start == 1) ? "w" : "W"
    let done_up_to = a:start
    "echo "searching for " . start_expr . " from " . line(".")
    while search(start_expr, flags) > 0
	let flags = "W"
	let first_line = line(".")
	"echo "MATCH " . start_expr . " " . first_line
	if first_line >= a:end || first_line < done_up_to
	    break
	endif
	if searchpair(start_expr, "", end_expr, "W") > 0
	    let last_line = line(".")
	    let done_up_to = last_line
	    if last_line <= a:end
		"echo "nested fold (" . a:start . " - " .  a:end . ") " .
		"     \ first_line . " - " . last_line
		execute ":" . first_line . "," . last_line . "fold"
		if last_line - first_line >= 2 && last_line <= a:end
		    call s:FoldNestableBlocks(first_line + 1, last_line - 1,
		    \                         start_expr, end_expr)
		endif
	    endif
	endif
    endwhile
    execute "normal " . origlineno . "G"
    "echo "RET " . a:start . " - " . a:end " -> " . origlineno
endfunction

"{{{~fold commands

if !exists(":Fold")
    command -nargs=1 Fold :call s:Foldsearch(<q-args>)
endif

"{{{ mappings and default options
if !hasmapto("<Plug>SimpleFold_Foldsearch")
    map <unique> <silent> <Leader>f <Plug>SimpleFold_Foldsearch
endif
noremap <unique> <script> <Plug>SimpleFold_Foldsearch <SID>FoldSearch
noremap <SID>FoldSearch :call <SID>Foldsearch("")<cr>

if !exists("g:SimpleFold_use_subfolds")
    let g:SimpleFold_use_subfolds = 1
endif

"{{{ Fold expressions for different filetypes

let g:simplefold_expr = '\v^\s*[#%"0-9]{0,4}\s*\{(\{\{|!!)'
let g:simplefold_marker_start = '\v\{\{\{\{'
let g:simplefold_marker_end = '\v\}\}\}\}'
" Ruby support
let g:ruby_simplefold_expr = 
	    \'\v(^\s*(def|class|module|attr_reader|attr_accessor|alias_method|' .
	    \    'attr|module_function|describe|it|before' . ')\s' . 
	    \ '|\v^\s*(public|private|protected)>' .
	    \ '|^\s*\w+attr_(reader|accessor)\s|^\s*[#%"0-9]{0,4}\s*\{\{\{[^{])' .
	    \ '|^\s*[A-Z]\w+\s*\=[^=]|^__END__$'
let g:ruby_simplefold_nestable_start_expr = 
	    \ '\v^\s*(def>|if>|unless>|while>.*(<do>)?|' . 
		\         'until>.*(<do>)?|case>|for>|begin>|it>|before>)' .
		\ '|^[^#]*.*<do>\s*(\|.*\|)?'
let g:ruby_simplefold_nestable_end_expr = '\v^\s*end'
    
let g:ruby_simplefold_prefix = '\v^\s*(#([^{]+|\{[^{]|\{\{[^{])*)?$'

" Java support
let g:java_simplefold_expr = 
	    \ '\(^\s*\(\(private\|public\|protected\|class\)\s\)\)'


" Perl support
let g:perl_simplefold_expr =
     \ '\v(^\s*(package|use|sub)>\s)'
let g:perl_simplefold_nestable_end_expr =
     \ '\v^\s*(\}|\);|\)\};)'                           
let g:perl_simplefold_prefix =
     \ '\v^\s*(#.*)?$'         
let g:perl_simplefold_nestable_start_expr =
	    \ '\v^\s*(((els)?if|for(each)?|unless|while)>\s*\(.*\)\s*\{' .
		\ '|else\s*\{' .
		    \ '|foreach>\s*my[^\(]+\s*\(.*\)\s*\{' .
		    \ '|(my>|our>)?\s*[@%\$].*\($)'

" PHP support
let g:php_simplefold_expr =
   \ '\v^\s*(interface|(abstract\s*)?class|(abstract\s*)?(public|private|protected|)(\s*static)?\s*function)>' .
   \ '|^\s*[#%"0-9]{0,4}\s*\{\{\{[^{]'
let g:php_simplefold_nestable_start_expr =
   \ '\v^\s*(if|for(each)?|while|switch)\s*\(.*\)\_s*\{'
let g:php_simplefold_nestable_end_expr =
   \ '\v^\s*\}'
let g:php_simplefold_prefix =
   \ '\v^\s*((/\*\_.*\*/)|((#|//).*))?$'

" Objective Caml support
let g:ocaml_simplefold_expr = 
   \ '\v(' .
   \ '^\s*(exception|type|module|and|class|val|method|inherit|initializer|include|open)>' .
   \ ')|(' .
   \ '^\s*($|\(\*.*\*\)\s*|\*.*\*\)\s*|.*struct\s*|((exception|type|open|include)>.*)|let.*(in|;|\=)@<!\s*)\n\s*let\zs\s' . 
   \ ')'
let g:ocaml_simplefold_nestable_start_expr = 
   \ '\v^\s*(if|match|try|for|while)(\s+|\s*$)'
let g:ocaml_simplefold_nestable_end_expr = 
   \ '\v^\s*$'

let g:ocaml_simplefold_prefix =
     \ '\v^\s*(\*.*|\(\*[^*]*|\(\*|.*\*\))?$'

let g:omlet_simplefold_expr = g:ocaml_simplefold_expr
let g:omlet_simplefold_nestable_start_expr = g:ocaml_simplefold_nestable_start_expr
let g:omlet_simplefold_nestable_end_expr = g:ocaml_simplefold_nestable_end_expr
let g:omlet_simplefold_prefix = g:ocaml_simplefold_prefix


let &cpo = s:save_cpo
