" EnhancedCommentify.vim
" Maintainer:	Meikel Brandmeyer <Brandels_Mikesh@web.de>
" Version:	2.2
" Last Change:	Monday, 27th September 2004

" License:
" Copyright (c) 2002,2003,2004 Meikel Brandmeyer, Kaiserslautern.
" All rights reserved.
"
" Redistribution and use in source and binary forms, with or without
" modification, are permitted provided that the following conditions are met:
"
"   * Redistributions of source code must retain the above copyright notice,
"     this list of conditions and the following disclaimer.
"   * Redistributions in binary form must reproduce the above copyright notice,
"     this list of conditions and the following disclaimer in the documentation
"     and/or other materials provided with the distribution.
"   * Neither the name of the author nor the names of its contributors may be
"     used to endorse or promote products derived from this software without
"     specific prior written permission.
"
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
" IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
" DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
" FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
" DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
" SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
" CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
" OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
" OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

" Description: 
" This is a (well... more or less) simple script to comment lines in a program.
" Currently supported languages are C, C++, PHP, the vim scripting
" language, python, HTML, Perl, LISP, Tex, Shell, CAOS and others.

" Bugfixes:
"   2.2
"   Fixed problem with UseSyntax (thanks to Pieter Naaijkens) 
"   Fixed typo in ParseCommentsOp (commstr -> commStr). 
"   Fixed support for ocaml (thanks to Zhang Le)
"   2.1
"   Fixed problems with alignement when a line contains tabs 
"   Fixed (resp. cleaned up) issues with overrideEL (thanks to Steve Hall) 
"   Fixed problems with javascript detection (thanks to Brian Neu) 
"   Changed Buffer init to BufWinEnter in order to use the modelines. 
"   2.0
"   Fixed invalid expression '\'' -> "'" (thanks to Zak Beck)
"   Setting AltOpen/AltClose to '' (ie. disabling it) would
"   insert '/*' resp. '*/' for character in a line (thanks to Ben Kibbey)
"   1.8
"   Backslashes in comment symbols should not be escaped.
"   typo (commensSymbol -> commentSymbol) (thanks to Steve Butts) 
"   typo (== -> =) 
"   Fixed hardwired '|+'-'+|' pair. 
"   1.7
"   Lines were not correctly decommentified, when there was whitespace
"   at the beginning of the line.    (thanks to Xiangjiang Ma) 
"   Fixed error detecting '*sh' filetypes. 
"   1.3
"   hlsearch was set unconditionally (thanks to Mary Ellen Foster)
"   made function silent	     (thanks to Mare Ellen Foster)

" Changelog:
"   2.2
"   Added possibility to override the modes, in which keybindings are
"   defined.
"   Keybindings may be defined local to every buffer now.
"   If a filetype is unknown, one can turn off the keybindings now. 
"   2.1
"   Removed any cursor movement. The script should now be free of
"   side-effects.
"   The script now uses &commentstring to determine the right
"   comment strings. Fallback is still the ugly if-thingy.
"   Script can now interpret &comments in order to add a middle
"   string in blocks.
"   Added EnhancedCommentifySet for use by other scripts. (Necessary?) 
"   Added MultiPartBlocks for languages with multipart-comments.
"   Added parsing for comments option if using MultiPartBlocks.
"   2.0
"   IMPORTANT: EnhancedCommentify is now licensed under BSD license
"              for distribution with Cream! However this shouldn't
"              change anything... 
"   useBlockIndent does no longer depend on respectIndent. 
"   Added code to cope with 'C' in '&cpo'. (thanks to Luc Hermitte
"   for pointing this out!)
"   Added EnhCommentifyIdentFrontOnly option.
"   All options are now handled on a per buffer basis. So options
"   can be overriden for different buffers. 
"   1.9
"   Filetype is now recognized via regular expressions.
"   All known filetypes are (more or less) supported.
"   Decomments multipart-block comments.
"   Added RespectIndent, AlignRight and synID-guessing.
"   Switched to buffer variables.
"   1.8
"   Added Ada support. (thanks to Preben Randhol) 
"   Added Latte support.
"   Added blocksupport and possibility to specify action (comment or
"   decomment). It's also possible to guess the action line by line or
"   using the first line of a block.
"   Thanks to Xiangjiang Ma and John Orr for the rich feedback on these
"   issues.
"   Decomments /*foo();*/, when PrettyComments is set.
"   Added 'vhdl' and 'verilog'. (thanks to Steve Butts) 
"   1.7
"   Added different options to control behaviour of the plugin. 
"   Changed default Keybindings to proper plugin settings.
"   1.6
"   Now supports 'm4', 'config', 'automake'
"   'vb', 'aspvbs', 'plsql' (thanks to Zak Beck)
"   1.5
"   Now supports 'java', 'xml', 'jproperties'. (thanks to Scott Stirling)
"   1.4
"   Lines containing only whitespace are now considered empty.
"   Added Tcl support.
"   Multipart comments are now escaped with configurable alternative
"   strings. Prevents nesting errors (eg. /**/*/ in C)
"   1.3
"   Doesn't break lines like
"	foo(); /* bar */
"   when doing commentify.

" Install Details:
" Simply drop this file into your $HOME/.vim/plugin directory.

if exists("DidEnhancedCommentify")
    finish
endif
let DidEnhancedCommentify = 1

let s:savedCpo = &cpo
set cpo-=C

" Note: These must be defined here, since they are used during
"       initialisation.
"
" InitBooleanVariable(confVar, scriptVar, defaultVal)
"	confVar		-- name of the configuration variable
"	scriptVar	-- name of the variable to set
"	defaultVal	-- default value
"
" Tests on existence of configuration variable and sets scriptVar
" according to its contents.
"
function s:InitBooleanVariable(confVar, scriptVar, defaultVal)
    let regex = a:defaultVal ? 'no*' : 'ye*s*'

    if exists(a:confVar) && {a:confVar} =~? regex
	let {a:scriptVar} = !a:defaultVal
    else
	let {a:scriptVar} = a:defaultVal
    endif
endfunction
    
"
" InitStringVariable(confVar, scriptVar, defaultVal)
"	confVar		-- name of the configuration variable
"	scriptVar	-- name of the variable to set
"	defaultVal	-- default value
"
" Tests on existence of configuration variable and sets scriptVar
" to its contents.
"
function s:InitStringVariable(confVar, scriptVar, defaultVal)
    if exists(a:confVar)
	execute "let ". a:scriptVar ." = ". a:confVar
    else
	let {a:scriptVar} = a:defaultVal
    endif
endfunction

"
" InitScriptVariables(nameSpace)
"	nameSpace	-- may be "g" for global or "b" for local
"
" Initialises the script variables.
"
function s:InitScriptVariables(nameSpace)
    let ns = a:nameSpace	" just for abbreviation
    let lns = (ns == "g") ? "s" : "b" " 'local namespace'

    " Comment escape strings...
    call s:InitStringVariable(ns .":EnhCommentifyAltOpen", lns .":ECaltOpen",
		\ s:ECaltOpen)
    call s:InitStringVariable(ns .":EnhCommentifyAltClose", lns .":ECaltClose",
		\ s:ECaltClose)

    call s:InitBooleanVariable(ns .":EnhCommentifyIgnoreWS", lns .":ECignoreWS",
		\ s:ECignoreWS)

    " Adding a space between comment strings and code...
    if exists(ns .":EnhCommentifyPretty")
	if {ns}:EnhCommentifyPretty =~? 'ye*s*'
	    let {lns}:ECprettyComments = ' '
	    let {lns}:ECprettyUnComments = ' \='
	else
	    let {lns}:ECprettyComments = ''
	    let {lns}:ECprettyUnComments = ''
	endif
    else
	let {lns}:ECprettyComments = s:ECprettyComments
	let {lns}:ECprettyUnComments = s:ECprettyUnComments
    endif

    " Identification string settings...
    call s:InitStringVariable(ns .":EnhCommentifyIdentString",
		\ lns .":ECidentFront", s:ECidentFront)
    let {lns}:ECidentBack =
		\ (exists(ns .":EnhCommentifyIdentFrontOnly")
		\	    && {ns}:EnhCommentifyIdentFrontOnly =~? 'ye*s*')
		\ ? ''
		\ : {lns}:ECidentFront

    " Wether to use syntax items...
    call s:InitBooleanVariable(ns .":EnhCommentifyUseSyntax",
		\ lns .":ECuseSyntax", s:ECuseSyntax)

    " Should the script respect line indentation, when inserting strings?
    call s:InitBooleanVariable(ns .":EnhCommentifyRespectIndent",
		\ lns .":ECrespectIndent", s:ECrespectIndent)

    " Keybindings...
    call s:InitBooleanVariable(ns .":EnhCommentifyUseAltKeys",
		\ lns .":ECuseAltKeys", s:ECuseAltKeys)
    call s:InitBooleanVariable(ns .":EnhCommentifyBindPerBuffer",
		\ lns .":ECbindPerBuffer", s:ECbindPerBuffer)
    call s:InitBooleanVariable(ns .":EnhCommentifyBindInNormal",
		\ lns .":ECbindInNormal", s:ECbindInNormal)
    call s:InitBooleanVariable(ns .":EnhCommentifyBindInInsert",
		\ lns .":ECbindInInsert", s:ECbindInInsert)
    call s:InitBooleanVariable(ns .":EnhCommentifyBindInVisual",
		\ lns .":ECbindInVisual", s:ECbindInVisual)
    call s:InitBooleanVariable(ns .":EnhCommentifyUserBindings",
		\ lns .":ECuserBindings", s:ECuserBindings)
    call s:InitBooleanVariable(ns .":EnhCommentifyTraditionalMode",
		\ lns .":ECtraditionalMode", s:ECtraditionalMode)
    call s:InitBooleanVariable(ns .":EnhCommentifyFirstLineMode",
		\ lns .":ECfirstLineMode", s:ECfirstLineMode)
    call s:InitBooleanVariable(ns .":EnhCommentifyUserMode",
		\ lns .":ECuserMode", s:ECuserMode)
    call s:InitBooleanVariable(ns .":EnhCommentifyBindUnknown",
		\ lns .":ECbindUnknown", s:ECbindUnknown)

    " Block stuff...
    call s:InitBooleanVariable(ns .":EnhCommentifyAlignRight",
		\ lns .":ECalignRight", s:ECalignRight)
    call s:InitBooleanVariable(ns .":EnhCommentifyUseBlockIndent",
		\ lns .":ECuseBlockIndent", s:ECuseBlockIndent)
    call s:InitBooleanVariable(ns .":EnhCommentifyMultiPartBlocks",
		\ lns .":ECuseMPBlock", s:ECuseMPBlock)
    call s:InitBooleanVariable(ns .":EnhCommentifyCommentsOp",
		\ lns .":ECuseCommentsOp", s:ECuseCommentsOp)

    let {lns}:ECsaveWhite = ({lns}:ECrespectIndent
		\ || {lns}:ECignoreWS || {lns}:ECuseBlockIndent)
		\	? '\(\s*\)'
		\	: ''

    if !{lns}:ECrespectIndent
	let {lns}:ECuseBlockIndent = 0
    endif

    if {lns}:ECrespectIndent
	let {lns}:ECrespectWhite = '\1'
	let {lns}:ECignoreWhite = ''
    elseif {lns}:ECignoreWS
	let {lns}:ECrespectWhite = ''
	let {lns}:ECignoreWhite = '\1'
    else
	let {lns}:ECrespectWhite = ''
	let {lns}:ECignoreWhite = ''
    endif

    " Using comments option, doesn't make sense without useMPBlock
    "if lns == 'b' && b:ECuseCommentsOp
    "	    let b:ECuseMPBlock = 1
    "endif
endfunction

"
" EnhancedCommentifySet(option, value, ...)
"	option	-- which option
"	value	-- value which will be asigned to the option
"
" The purpose of this function is mainly to act as an interface to the
" outer world. It hides the internally used variables.
"
function EnhancedCommentifySet(option, value)
    if a:option == 'AltOpen'
	let oldval = b:ECaltOpen
	let b:ECaltOpen = a:value
    elseif a:option == 'AltClose'
	let oldval = b:ECaltClose
	let b:ECaltClose = a:value
    elseif a:option == 'IdentString'
	let oldval = b:ECidentFront
	let b:ECidentFront = a:value
    elseif a:option == 'IdentFrontOnly'
	let oldval = (b:ECidentBack == '') ? 'Yes' : 'No'
	let b:ECidentBack = (a:value =~? 'ye*s*') ? '' : b:ECidentFront
    elseif a:option == 'RespectIndent'
	let oldval = b:ECrespectIndent
	let b:ECrespectIndent = (a:value =~? 'ye*s*') ? 1 : 0
    elseif a:option == 'IgnoreWS'
	let oldval = b:ECignoreWS
	let b:ECignoreWS = (a:value =~? 'ye*s*') ? 1 : 0
    elseif a:option == 'Pretty'
	let oldval = (b:ECprettyComments == ' ') ? 'Yes' : 'No'
	if a:value =~? 'ye*s*'
	    let b:ECprettyComments = ' '
	    let b:ECprettyUnComments = ' \='
	else
	    let b:ECprettyComments = ''
	    let b:ECprettyUnComments = ''
	endif
    elseif a:option == 'MultiPartBlocks'
	let oldval = b:ECuseMPBlock
	let b:ECuseMPBlock = (a:value =~? 'ye*s*') ? 1 : 0
    elseif a:option == 'CommentsOp'
	let oldval = b:ECuseCommentsOp
	let b:ECuseCommentsOp = (a:value =~? 'ye*s*') ? 1 : 0
    elseif a:option == 'UseBlockIndent'
	let oldval = b:ECuseBlockIndent
	let b:ECuseBlockIndent = (a:value =~? 'ye*s*') ? 1 : 0
    elseif a:option == 'AlignRight'
	let oldval = b:ECalignRight
	let b:ECalignRight = (a:value =~? 'ye*s*') ? 1 : 0
    elseif a:option == 'UseSyntax'
	let oldval = b:ECuseSyntax
	let b:ECuseSyntax = (a:value =~? 'ye*s*') ? 1 : 0
    else
	if (has("dialog_gui") && has("gui_running"))
	    call confirm("EnhancedCommentifySet: Unknwon option '"
			\ . option . "'")
	else
	    echohl ErrorMsg
	    echo "EnhancedCommentifySet: Unknown option '". option ."'"
	    echohl None
	endif
    endif

    if oldval == 1
	let oldval = 'Yes'
    elseif oldval == 0
	let oldval = 'No'
    endif

    return oldval
endfunction

" Initial settings.
"
" Setting the default options resp. taking user preferences.
if !exists("g:EnhCommentifyUserMode")
	    \ && !exists("g:EnhCommentifyFirstLineMode")
	    \ && !exists("g:EnhCommentifyTraditionalMode")
	    \ && !exists("g:EnhCommentifyUserBindings")
    let g:EnhCommentifyTraditionalMode = 'Yes'
endif

" These will be the default settings for the script:
let s:ECaltOpen = "|+"
let s:ECaltClose = "+|"
let s:ECignoreWS = 1
let s:ECprettyComments = ''
let s:ECprettyUnComments = ''
let s:ECidentFront = ''
let s:ECuseSyntax = 0
let s:ECrespectIndent = 0
let s:ECalignRight = 0
let s:ECuseBlockIndent = 0
let s:ECuseMPBlock = 0
let s:ECuseCommentsOp = 0
let s:ECuseAltKeys = 0
let s:ECbindPerBuffer = 0
let s:ECbindInNormal = 1
let s:ECbindInInsert = 1
let s:ECbindInVisual = 1
let s:ECuserBindings = 0
let s:ECtraditionalMode = 0
let s:ECfirstLineMode = 0
let s:ECuserMode = 1
let s:ECbindUnknown = 1

" Now initialise the global defaults with the preferences set
" by the user in his .vimrc. Settings local to a buffer will be
" done later on, when the script is first called in a buffer.
"
call s:InitScriptVariables("g")

" Globally used variables with some initialisation.
" FIXME: explain what they are good for
" 
let s:Action = 'guess'
let s:firstOfBlock = 1
let s:blockAction = 'comment'
let s:blockIndentRegex = ''
let s:blockIndent = 0
let s:inBlock = 0
let s:tabConvert = ''
let s:overrideEmptyLines = 0
let s:emptyLines = 'no'
let s:maxLen = 0

function EnhancedCommentifyInitBuffer()
    if !exists("b:ECdidBufferInit")
	call s:InitScriptVariables("b")
	
	if !exists("b:EnhCommentifyFallbackTest")
	    let b:EnhCommentifyFallbackTest = 0
	endif

	call s:GetFileTypeSettings(&ft)
	call s:CheckPossibleEmbedding(&ft)

	"
	" If the filetype is not supported and the user wants us to, we do not
	" add keybindings.
	"
	if s:ECbindPerBuffer
	    if b:ECcommentOpen != "" || b:ECbindUnknown
		call s:SetKeybindings("l")
	    endif
	endif

	let b:ECdidBufferInit = 1
	let b:ECsyntax = &ft
    endif
endfunction

autocmd BufWinEnter,BufNewFile  *	call EnhancedCommentifyInitBuffer()

"
" EnhancedCommentify(emptyLines, action, ...)
"	overrideEL	-- commentify empty lines
"			   may be 'yes', 'no' or '' for guessing
"	action		-- action which should be executed:
"			    * guess:
"			      toggle commetification (old behaviour)
"			    * comment:
"			      comment lines
"			    * decomment:
"			      decomment lines
"			    * first:
"			      use first line of block to determine action 
"	a:1, a:2	-- first and last line of block, which should be
"			   processed. 
"
" Commentifies the current line.
"
function EnhancedCommentify(overrideEL, action, ...)
    if a:overrideEL != ''
	let s:overrideEmptyLines = 1
    endif

    " Now do the buffer initialisation. Every buffer will get
    " it's pendant to a global variable (eg. s:ECalignRight -> b:ECalignRight).
    " The local variable is actually used, whereas the global variable
    " holds the defaults from the user's .vimrc. In this way the settings
    " can be overriden for single buffers.
    " 
    " NOTE: Buffer init is done by autocommands now.
    "

    let b:ECemptyLines = a:overrideEL

    " The language is not supported.
    if b:ECcommentOpen == ''
	if (has("dialog_gui") && has("gui_running"))
	    call confirm("This filetype is currently _not_ supported!\n"
			\ ."Please consider contacting the author in order"
			\ ." to add this filetype.", "", 1, "Error")
	else
	    echohl ErrorMsg
	    echo "This filetype is currently _not_ supported!"
	    echo "Please consider contacting the author in order to add"
	    echo "this filetype in future releases!"
	    echohl None
	endif
	return
    endif

    let lnum = line(".")

    " Now some initialisations...
    let s:Action = a:action

    " FIXME: Is there really _no_ function to simplify this???
    " (Maybe something like 'let foo = 8x" "'?) 
    if s:tabConvert == '' && strlen(s:tabConvert) != &tabstop
	let s:tabConvert = ''
	let i = 0
	while i < &tabstop
	    let s:tabConvert = s:tabConvert .' '
	    let i = i + 1
	endwhile
    endif

    if a:0 == 2
	let s:startBlock = a:1
	let s:i = a:1
	let s:endBlock = a:2

	let s:inBlock = 1
    else
	let s:startBlock = lnum
	let s:i = lnum
	let s:endBlock = lnum

	let s:inBlock = 0
    endif

    if b:ECuseSyntax && b:ECpossibleEmbedding
	let column = indent(s:startBlock) + 1
	if !&expandtab
		let rem = column % &tabstop
		let column = ((column - rem) / &tabstop) + rem
	endif
	call s:CheckSyntax(s:startBlock, column)
    endif

    " Get the indent of the less indented line of the block.
    if s:inBlock && (b:ECuseBlockIndent || b:ECalignRight)
	call s:DoBlockComputations(s:startBlock, s:endBlock)
    endif

    while s:i <= s:endBlock
	let lineString = getline(s:i)
	let lineString = s:TabsToSpaces(lineString) 

	" If we should comment "empty" lines, we have to add
	" the correct indent, if we use blockIndent.
	if b:ECemptyLines =~? 'ye*s*'
			\ && b:ECuseBlockIndent
			\ && lineString =~ "^\s*$"
	    let i = 0
	    while i < s:blockIndent
		let lineString = " " . lineString
		let i = i + 1
	    endwhile
	endif

	" Don't comment empty lines.
	if lineString !~ "^\s*$"
		    \ || b:ECemptyLines =~? 'ye*s*'
	    if b:ECcommentClose != ''
		let lineString = s:CommentifyMultiPart(lineString,
			    \ b:ECcommentOpen,
			    \ b:ECcommentClose,
			    \ b:ECcommentMiddle)
	    else
	    	let lineString = s:CommentifySinglePart(lineString,
			    \ b:ECcommentOpen)
	    endif
	endif

	" Revert the above: If the line is "empty" and we
	" used blockIndent, we remove the spaces.
	" FIXME: Why does "^\s*$" not work? 
	if b:ECemptyLines =~? 'ye*s*'
		    \ && b:ECuseBlockIndent
		    \ && lineString =~ "^" . s:blockIndentRegex ."\s*$"
	    let lineString =
			\ substitute(lineString, s:blockIndentRegex,
			\     '', '')
	endif

	let lineString = s:SpacesToTabs(lineString)
	call setline(s:i, lineString)

	let s:i = s:i + 1
	let s:firstOfBlock = 0
    endwhile

    let s:firstOfBlock = 1
endfunction

"
" DoBlockComputations(start, end)
"	    start	-- number of first line
"	    end		-- number of last line
"
" This function does some computations which are necessary for useBlockIndent
" and alignRight. ie. find smallest indent and longest line.
"
function s:DoBlockComputations(start, end)
    let i = a:start
    let len = 0
    let amount = 100000	    " this should be enough ...
    
    while i <= a:end
	if b:ECuseBlockIndent && getline(i) !~ '^\s*$'
	    let cur = indent(i)
	    if cur < amount
		let amount = cur
	    endif
	endif

	if b:ECalignRight
	    let cur = s:GetLineLen(s:TabsToSpaces(getline(i)),
			\ s:GetLineLen(b:ECcommentOpen, 0)
			\ + strlen(b:ECprettyComments))
	    if b:ECuseMPBlock
		let cur = cur + s:GetLineLen(b:ECcommentOpen, 0)
			    \ + strlen(b:ECprettyComments)
	    endif

	    if len < cur
		let len = cur
	    endif
	endif
	
	let i = i + 1
    endwhile

    if b:ECuseBlockIndent
	if amount > 0
	    let regex = '\( \{'. amount .'}\)'
	else
	    let regex = ''
	endif
	let s:blockIndentRegex = regex
	let s:blockIndent = amount
    endif

    if b:ECalignRight
	let s:maxLen = len
    endif
endfunction

"
" CheckSyntax(line, column)
"	line	    -- line of line
"	column	    -- column of line
" Check what syntax is active during call of main function. First hit
" wins. If the filetype changes during the block, we ignore that.
" Adjust the filetype if necessary.
"
function s:CheckSyntax(line, column)
    let ft = ""
    let synFiletype = synIDattr(synID(a:line, a:column, 1), "name")

    " FIXME: This feature currently relies on a certain format
    " of the names of syntax items: the filetype must be prepended
    " in lowwer case letters, followed by at least one upper case
    " letter.
    if match(synFiletype, '\l\+\u') == 0
	let ft = substitute(synFiletype, '^\(\l\+\)\u.*$', '\1', "")
    endif

    if ft == ""
	execute "let specialCase = ". b:EnhCommentifyFallbackTest

	if specialCase
	    let ft = b:EnhCommentifyFallbackValue
	else
	    " Fallback: If nothing holds, use normal filetype!
	    let ft = &ft
	endif
    endif
    
    " Nothing changed!
    if ft == b:ECsyntax
	return
    endif

    let b:ECsyntax = ft
    call s:GetFileTypeSettings(ft)
endfunction

"
" GetFileTypeSettings(ft)
"	ft	    -- filetype
"
" This functions sets some buffer-variables, which control the comment
" strings and 'empty lines'-handling.
"
function s:GetFileTypeSettings(ft)
    let fileType = a:ft

    " I learned about the commentstring option. Let's use it.
    " For now we ignore it, if it is "/*%s*/". This is the
    " default. We cannot check wether this is default or C or
    " something other like CSS, etc. We have to wait, until the
    " filetypes adopt this option.
    if &commentstring != "/*%s*/" && !b:ECuseSyntax
	let b:ECcommentOpen =
		    \ substitute(&commentstring, '%s.*', "", "")
	let b:ECcommentClose =
		    \ substitute(&commentstring, '.*%s', "", "")
    " Multipart comments:
    elseif fileType =~ '^\(c\|b\|css\|csc\|cupl\|indent\|jam\|lex\|lifelines\|'.
		\ 'lite\|nqc\|phtml\|progress\|rexx\|rpl\|sas\|sdl\|sl\|'.
		\ 'strace\|xpm\|yacc\)$'
	let b:ECcommentOpen = '/*'
	let b:ECcommentClose = '*/'
    elseif fileType =~ '^\(html\|xml\|dtd\|sgmllnx\)$'
	let b:ECcommentOpen = '<!--'
	let b:ECcommentClose = '-->'
    elseif fileType =~ '^\(sgml\|smil\)$'
	let b:ECcommentOpen = '<!'
	let b:ECcommentClose = '>'
    elseif fileType == 'atlas'
	let b:ECcommentOpen = 'C'
	let b:ECcommentClose = '$'
    elseif fileType =~ '^\(catalog\|sgmldecl\)$'
	let b:ECcommentOpen = '--'
	let b:ECcommentClose = '--'
    elseif fileType == 'dtml'
	let b:ECcommentOpen = '<dtml-comment>'
	let b:ECcommentClose = '</dtml-comment>'
    elseif fileType == 'htmlos'
	let b:ECcommentOpen = '#'
	let b:ECcommentClose = '/#'
    elseif fileType =~ '^\(jgraph\|lotos\|mma\|modula2\|modula3\|pascal\|'.
		\ 'ocaml\|sml\)$'
	let b:ECcommentOpen = '(*'
	let b:ECcommentClose = '*)'
    elseif fileType == 'jsp'
	let b:ECcommentOpen = '<%--'
	let b:ECcommentClose = '--%>'
    elseif fileType == 'model'
	let b:ECcommentOpen = '$'
	let b:ECcommentClose = '$'
    elseif fileType == 'st'
	let b:ECcommentOpen = '"'
	let b:ECcommentClose = '"'
    elseif fileType =~ '^\(tssgm\|tssop\)$'
	let b:ECcommentOpen = 'comment = "'
	let b:ECcommentClose = '"'
    " Singlepart comments:
    elseif fileType =~ '^\(ox\|cpp\|php\|java\|verilog\|acedb\|ch\|clean\|'.
		\ 'clipper\|cs\|dot\|dylan\|hercules\|idl\|ishd\|javascript\|'.
		\ 'kscript\|mel\|named\|openroad\|pccts\|pfmain\|pike\|'.
		\ 'pilrc\|plm\|pov\|rc\|scilab\|specman\|tads\|tsalt\|uc\|'.
		\ 'xkb\)$'
	let b:ECcommentOpen = '//'
	let b:ECcommentClose = ''
    elseif fileType =~ '^\(vim\|abel\)$'
	let b:ECcommentOpen = '"'
	let b:ECcommentClose = ''
    elseif fileType =~ '^\(lisp\|scheme\|scsh\|amiga\|asm\|asm68k\|bindzone\|'.
		\ 'def\|dns\|dosini\|dracula\|dsl\|idlang\|iss\|jess\|kix\|'.
		\ 'masm\|monk\|nasm\|ncf\|omnimark\|pic\|povini\|rebol\|'.
		\ 'registry\|samba\|skill\|smith\|tags\|tasm\|tf\|winbatch\|'.
		\ 'wvdial\|z8a\)$'
	let b:ECcommentOpen = ';'
	let b:ECcommentClose = ''
    elseif fileType =~ '^\(python\|perl\|[^w]*sh$\|tcl\|jproperties\|make\|'.
		\ 'robots\|apacha\|apachestyle\|awk\|bc\|cfg\|cl\|conf\|'.
		\ 'crontab\|diff\|ecd\|elmfilt\|eterm\|expect\|exports\|'.
		\ 'fgl\|fvwm\|gdb\|gnuplot\|gtkrc\|hb\|hog\|ia64\|icon\|'.
		\ 'inittab\|lftp\|lilo\|lout\|lss\|lynx\|maple\|mush\|'.
		\ 'muttrc\|nsis\|ora\|pcap\|pine\|po\|procmail\|'.
		\ 'psf\|ptcap\|r\|radiance\|ratpoison\|readline\remind\|'.
		\ 'ruby\|screen\|sed\|sm\|snnsnet\|snnspat\|snnsres\|spec\|'.
		\ 'squid\|terminfo\|tidy\|tli\|tsscl\|vgrindefs\|vrml\|'.
		\ 'wget\|wml\|xf86conf\|xmath\)$'
	let b:ECcommentOpen = '#'
	let b:ECcommentClose = ''
    elseif fileType == 'webmacro'
	let b:ECcommentOpen = '##'
	let b:ECcommentClose = ''
    elseif fileType == 'ppwiz'
	let b:ECcommentOpen = ';;'
	let b:ECcommentClose = ''
    elseif fileType == 'latte'
	let b:ECcommentOpen = '\\;'
	let b:ECcommentClose = ''
    elseif fileType =~ '^\(tex\|abc\|erlang\|ist\|lprolog\|matlab\|mf\|'.
		\ 'postscr\|ppd\|prolog\|simula\|slang\|slrnrc\|slrnsc\|'.
		\ 'texmf\|virata\)$'
	let b:ECcommentOpen = '%'
	let b:ECcommentClose = ''
    elseif fileType =~ '^\(caos\|cterm\|form\|foxpro\|sicad\|snobol4\)$'
	let b:ECcommentOpen = '*'
	let b:ECcommentClose = ''
    elseif fileType =~ '^\(m4\|config\|automake\)$'
	let b:ECcommentOpen = 'dnl '
	let b:ECcommentClose = ''
    elseif fileType =~ '^\(vb\|aspvbs\|ave\|basic\|elf\|lscript\)$'
	let b:ECcommentOpen = "'"
	let b:ECcommentClose = ''
    elseif fileType =~ '^\(plsql\|vhdl\|ahdl\|ada\|asn\|csp\|eiffel\|gdmo\|'.
		\ 'haskell\|lace\|lua\|mib\|sather\|sql\|sqlforms\|sqlj\|'.
		\ 'stp\)$'
	let b:ECcommentOpen = '--'
	let b:ECcommentClose = ''
    elseif fileType == 'abaqus'
	let b:ECcommentOpen = '**'
	let b:ECcommentClose = ''
    elseif fileType =~ '^\(aml\|natural\|vsejcl\)$'
	let b:ECcommentOpen = '/*'
	let b:ECcommentClose = ''
    elseif fileType == 'ampl'
	let b:ECcommentOpen = '\\#'
	let b:ECcommentClose = ''
    elseif fileType == 'bdf'
	let b:ECcommentOpen = 'COMMENT '
	let b:ECcommentClose = ''
    elseif fileType == 'btm'
	let b:ECcommentOpen = '::'
	let b:ECcommentClose = ''
    elseif fileType == 'dcl'
	let b:ECcommentOpen = '$!'
	let b:ECcommentClose = ''
    elseif fileType == 'dosbatch'
	let b:ECcommentOpen = 'rem '
	let b:ECcommentClose = ''
    elseif fileType == 'focexec'
	let b:ECcommentOpen = '-*'
	let b:ECcommentClose = ''
    elseif fileType == 'forth'
	let b:ECcommentOpen = '\\ '
	let b:ECcommentClose = ''
    elseif fileType =~ '^\(fortran\|inform\|sqr\|uil\|xdefaults\|'.
		\ 'xmodmap\|xpm2\)$'
	let b:ECcommentOpen = '!'
	let b:ECcommentClose = ''
    elseif fileType == 'gp'
	let b:ECcommentOpen = '\\\\'
	let b:ECcommentClose = ''
    elseif fileType =~ '^\(master\|nastran\|sinda\|spice\|tak\|trasys\)$'
	let b:ECcommentOpen = '$'
	let b:ECcommentClose = ''
    elseif fileType == 'nroff' || fileType == 'groff'
	let b:ECcommentOpen = ".\\\\\""
	let b:ECcommentClose = ''
    elseif fileType == 'opl'
	let b:ECcommentOpen = 'REM '
	let b:ECcommentClose = ''
    elseif fileType == 'texinfo'
	let b:ECcommentOpen = '@c '
	let b:ECcommentClose = ''
    else 
	let b:ECcommentOpen = ''
	let b:ECcommentClose = ''
    endif

    if b:ECuseCommentsOp
	let b:ECcommentMiddle =
		    \ s:ParseCommentsOp(b:ECcommentOpen, b:ECcommentClose)
	if b:ECcommentMiddle == ''
	    let b:ECuseCommentsOp = 0
	endif
    else
	let b:ECcommentMiddle = ''
    endif

    if !s:overrideEmptyLines
	call s:CommentEmptyLines(fileType)
    endif
endfunction

"
" ParseCommentsOp(commentOpen, commentClose)
"	commentOpen -- comment-open string
"	commentClose-- comment-close string
"
" Try to extract the middle comment string from &comments. First hit wins.
" If nothing is found '' is returned.
"
function s:ParseCommentsOp(commentOpen, commentClose)
    let commStr = &comments
    let offset = 0
    let commentMiddle = ''

    while commStr != ''
	"
	" First decompose &omments into consecutive s-, m- and e-parts.
	"
	let s = stridx(commStr, 's')
	if s == -1
	    return ''
	endif

	let commStr = strpart(commStr, s)
	let comma = stridx(commStr, ',')
	if comma == -1
	    return ''
	endif
	let sPart = strpart(commStr, 0, comma)

	let commStr = strpart(commStr, comma)
	let m = stridx(commStr, 'm')
	if m == -1
	    return ''
	endif

	let commStr = strpart(commStr, m)
	let comma = stridx(commStr, ',')
	if comma == -1
	    return ''
	endif
	let mPart = strpart(commStr, 0, comma)

	let commStr = strpart(commStr, comma)
	let e = stridx(commStr, 'e')
	if e == -1
	    return ''
	endif

	let commStr = strpart(commStr, e)
	let comma = stridx(commStr, ',')
	if comma == -1
	    let comma = strlen(commStr)
	endif
	let ePart = strpart(commStr, 0, comma)

	let commStr = strpart(commStr, comma)

	"
	" Now check wether this is what we want:
	" Are the comment string the same?
	"
	let sColon = stridx(sPart, ':')
	let eColon = stridx(ePart, ':')
	if sColon == -1 || eColon == -1
	    return ''
	endif
	if strpart(sPart, sColon + 1) != a:commentOpen
		    \ || strpart(ePart, eColon + 1) != a:commentClose
	    continue
	endif

	let mColon = stridx(mPart, ':')
	if mColon == -1
	    return ''
	endif
	let commentMiddle = strpart(mPart, mColon + 1)

	"
	" Check for any alignement.
	"
	let i = 1
	while sPart[i] != ':'
	    if sPart[i] == 'r'
		let offset = strlen(a:commentOpen) - strlen(commentMiddle)
		break
	    elseif sPart[i] == 'l'
		let offset = 0
		break
	    elseif s:isDigit(sPart[i])
		let j = 1
		while s:isDigit(sPart[i + j])
		    let j = j + 1
		endwhile
		let offset = 1 * strpart(sPart, i, j)
		break
	    endif
	    let i = i + 1
	endwhile

	if offset == 0
	    let i = 1
	    while ePart[i] != ':'
		if ePart[i] == 'r'
		    let offset = strlen(a:commentClose) - strlen(commentMiddle)
		    break
		elseif ePart[i] == 'l'
		    let offset = 0
		    break
		elseif s:isDigit(ePart[i])
		    let j = 1
		    while s:isDigit(ePart[i + j])
			let j = j + 1
		    endwhile
		    let offset = 1 * strpart(ePart, i, j)
		    break
		endif

		let i = i + 1
	    endwhile
	endif

	while offset > 0
	    let commentMiddle = " " . commentMiddle
	    let offset = offset - 1
	endwhile

	break
    endwhile

    return commentMiddle
endfunction

"
" isDigit(char)
"
" Nomen est Omen.
"
function s:isDigit(char)
    let r = 0

    let charVal = char2nr(a:char)

    if charVal >= 48 && charVal <= 57
	let r = 1
    endif

    return r
endfunction

"
" CommentEmptyLines(ft)
"	ft	    -- filetype of current buffer
"
" Decides, if empty lines should be commentified or not. Add the filetype,
" you want to change, to the apropriate if-clause.
"
function s:CommentEmptyLines(ft)
    " FIXME: Quick hack (tm)!
    if 0
	" Add special filetypes here.
    elseif b:ECcommentClose == ''
	let b:ECemptyLines = 'yes'
    else
	let b:ECemptyLines = 'no'
    endif
endfunction

"
" CheckPossibleEmbedding(ft)
"	ft	-- the filetype of current buffer
"
" Check wether it makes sense to allow checking for the synIDs.
" Eg. C will never have embedded code...
"
function s:CheckPossibleEmbedding(ft)
    if a:ft =~ '^\(php\|vim\|latte\|html\)$'
	let b:ECpossibleEmbedding = 1
    else
	" Since getting the synID is slow, we set the default to 'no'!
	" There are also some 'broken' languages like the filetype for
	" autoconf's configure.in's ('config'). 
	let b:ECpossibleEmbedding = 0
    endif
endfunction

"
" CommentifyMultiPart(lineString, commentStart, commentEnd, action)
"	lineString	-- line to commentify
"	commentStart	-- comment-start string, eg '/*'
"	commentEnd	-- comment-end string, eg. '*/'
"	commentMiddle	-- comment-middle string, eg. ' *'	
"
" This function commentifies code of languages, which have multipart
" comment strings, eg. '/*' - '*/' of C.
"
function s:CommentifyMultiPart(lineString, commentStart,
	    \ commentEnd, commentMiddle)
    if s:Action == 'guess' || s:Action == 'first' || b:ECuseMPBlock
	let todo = s:DecideWhatToDo(a:lineString, a:commentStart, a:commentEnd)
    else
	let todo = s:Action
    endif

    if todo == 'decomment'
	return s:UnCommentify(a:lineString, a:commentStart,
		    \ a:commentEnd, a:commentMiddle)
    else
	return s:Commentify(a:lineString, a:commentStart,
		    \ a:commentEnd, a:commentMiddle)
    endif
endfunction

"
" CommentifySinglePart(lineString, commentSymbol)
"	lineString	-- line to commentify
"	commentSymbol	-- comment string, eg '#'
"
" This function is used for all languages, whose comment strings
" consist only of one string at the beginning of a line.
"
function s:CommentifySinglePart(lineString, commentSymbol)
    if s:Action == 'guess' || s:Action == 'first'
	let todo = s:DecideWhatToDo(a:lineString, a:commentSymbol)
    else
	let todo = s:Action
    endif

    if todo == 'decomment'
	return s:UnCommentify(a:lineString, a:commentSymbol)
    else
	return s:Commentify(a:lineString, a:commentSymbol)
    endif
endfunction

"
" Escape(lineString, commentStart, commentEnd)
"
" Escape already present symbols.
"
function s:Escape(lineString, commentStart, commentEnd)
    let line = a:lineString

    if b:ECaltOpen != ''
	let line = substitute(line, s:EscapeString(a:commentStart),
		    \ b:ECaltOpen, "g")
    endif
    if b:ECaltClose != ''
	let line = substitute(line, s:EscapeString(a:commentEnd),
		    \ b:ECaltClose, "g")
    endif

    return line
endfunction

"
" UnEscape(lineString, commentStart, commentEnd)
"
" Unescape already present escape symbols.
"
function s:UnEscape(lineString, commentStart, commentEnd)
    let line = a:lineString

    if b:ECaltOpen != ''
	let line = substitute(line, s:EscapeString(b:ECaltOpen),
		    \ a:commentStart, "g")
    endif
    if b:ECaltClose != ''
	let line = substitute(line, s:EscapeString(b:ECaltClose),
		    \ a:commentEnd, "g")
    endif

    return line
endfunction

"
" Commentify(lineString, commentSymbol, [commentEnd])
"       lineString	-- the line in work
"	commentSymbol	-- string to insert at the beginning of the line
"	commentEnd	-- string to insert at the end of the line
"			   may be omitted
"
" This function inserts the start- (and if given the end-) string of the
" comment in the current line.
"
function s:Commentify(lineString, commentSymbol, ...)
    let line = a:lineString
    let j = 0

    " If a end string is present, insert it too.
    if a:0 > 0
	" First we have to escape any comment already contained in the line,
	" since (at least for C) comments are not allowed to nest.
	let line = s:Escape(line, a:commentSymbol, a:1)

	if b:ECuseCommentsOp && b:ECuseMPBlock
		    \ && a:0 > 1
		    \ && s:i > s:startBlock
	    let line = substitute(line, s:LookFor('commentmiddle'),
			\ s:SubstituteWith('commentmiddle', a:2), "")
	endif
	    
	if !b:ECuseMPBlock || (b:ECuseMPBlock && s:i == s:endBlock)
	    " Align the closing part to the right.
	    if b:ECalignRight && s:inBlock
		let len = s:GetLineLen(line, strlen(a:commentSymbol)
			    \ + strlen(b:ECprettyComments))
		while j < s:maxLen - len
		    let line = line .' '
		    let j = j + 1
		endwhile
	    endif

	    let line = substitute(line, s:LookFor('commentend'),
			\ s:SubstituteWith('commentend', a:1), "")
	endif
    endif
    
    " insert the comment symbol
    if !b:ECuseMPBlock || a:0 == 0 || (b:ECuseMPBlock && s:i == s:startBlock) 
	let line = substitute(line, s:LookFor('commentstart'),
		    \ s:SubstituteWith('commentstart', a:commentSymbol), "")
    endif
    
    return line
endfunction

"
" UnCommentify(lineString, commentSymbol, [commentEnd])
"	lineString	-- the line in work
"	commentSymbol	-- string to remove at the beginning of the line
"	commentEnd	-- string to remove at the end of the line
"			   may be omitted
"
" This function removes the start- (and if given the end-) string of the
" comment in the current line.
"
function s:UnCommentify(lineString, commentSymbol, ...)
    let line = a:lineString

    " remove the first comment symbol found on a line
    if a:0 == 0 || !b:ECuseMPBlock || (b:ECuseMPBlock && s:i == s:startBlock) 
	let line = substitute(line, s:LookFor('decommentstart',
		    \	a:commentSymbol),
		    \ s:SubstituteWith('decommentstart'), "")
    endif

    " If a end string is present, we have to remove it, too.
    if a:0 > 0
	" First, we remove the trailing comment symbol.
	if !b:ECuseMPBlock || (b:ECuseMPBlock && s:i == s:endBlock) 
	    let line = substitute(line, s:LookFor('decommentend', a:1),
			\ s:SubstituteWith('decommentend'), "")

	    " Remove any trailing whitespace, if we used alignRight.
	    if b:ECalignRight
		let line = substitute(line, ' *$', '', "")
	    endif
	endif

	" Maybe we added a middle string. Remove it here.
	if b:ECuseCommentsOp && b:ECuseMPBlock
		    \ && a:0 > 1
		    \ && s:i > s:startBlock
	    let line = substitute(line, s:LookFor('decommentmiddle', a:2),
			\ s:SubstituteWith('decommentmiddle'), "")
	endif

	" Remove escaped inner comments.
	let line = s:UnEscape(line, a:commentSymbol, a:1)
    endif

    return line
endfunction

"
" GetLineLen(line, offset)
"	line	    -- line of which length should be computed
"	offset	    -- maybe a shift of the line to the right
"
" Expands '\t' to it's tabstop value.
"
function s:GetLineLen(line, offset)
    let len = a:offset
    let i = 0
    
    while a:line[i] != ""
	if a:line[i] == "\t"
	    let len = (((len / &tabstop) + 1) * &tabstop)
	else
	    let len = len + 1
	endif
	let i = i + 1
    endwhile

    return len
endfunction
     
"
" EscapeString(string)
"	string	    -- string to process
"
" Escapes characters in 'string', which have some function in
" regular expressions, with a '\'.
"
" Returns the escaped string.
"
function s:EscapeString(string)
    return escape(a:string, "*{}[]$^-")
endfunction

"
" LookFor(what, ...)
"	what	    -- what type of regular expression
"			* checkstart:
"			* checkend:
"			  check for comment at start/end of line
"			* commentstart:
"			* commentend:
"			  insert comment strings
"			* decommentstart:
"			* decommentend:
"			  remove comment strings
"	a:1	    -- comment string
"
function s:LookFor(what, ...)
    if b:ECuseBlockIndent && s:inBlock
	let handleWhitespace = s:blockIndentRegex
    else
	let handleWhitespace = b:ECsaveWhite
    endif
	
    if a:what == 'checkstart'
	let regex = '^'. b:ECsaveWhite . s:EscapeString(a:1)
		    \ . s:EscapeString(b:ECidentFront)
    elseif a:what == 'checkend'
	let regex = s:EscapeString(b:ECidentBack)
		    \ . s:EscapeString(a:1) . b:ECsaveWhite . '$'
    elseif a:what == 'commentstart'
	let regex = '^'. handleWhitespace
    elseif a:what == 'commentmiddle'
	let regex = '^'. handleWhitespace
    elseif a:what == 'commentend'
	let regex = '$'
    elseif a:what == 'decommentstart'
	let regex = '^'. b:ECsaveWhite . s:EscapeString(a:1)
    		    \ . s:EscapeString(b:ECidentFront) . b:ECprettyUnComments
    elseif a:what == 'decommentmiddle'
	let regex = '^'. b:ECsaveWhite . s:EscapeString(a:1)
		    \ . s:EscapeString(b:ECidentFront) . b:ECprettyUnComments
    elseif a:what == 'decommentend'
	let regex = b:ECprettyUnComments . s:EscapeString(b:ECidentBack)
		    \ . s:EscapeString(a:1) . b:ECsaveWhite .'$'
    endif

    return regex
endfunction

"
" SubstituteWith(what, ...)
"	what	    -- what type of regular expression
"			* commentstart:
"			* commentend:
"			  insert comment strings
"			* decommentstart:
"			* decommentend:
"			  remove comment strings
"	a:1	    -- comment string
"
function s:SubstituteWith(what, ...)
    if a:what == 'commentstart'
		\ || a:what == 'commentmiddle'
		\ || a:what == 'commentend'
	let commentSymbol = a:1
    else
	let commentSymbol = ''
    endif

    if b:ECuseBlockIndent && s:inBlock
	let handleWhitespace = '\1' . commentSymbol
    else
	let handleWhitespace = b:ECrespectWhite . commentSymbol
		    \ . b:ECignoreWhite
    endif
	
    if a:what == 'commentstart'
	let regex = handleWhitespace . b:ECidentFront
		    \ . b:ECprettyComments
    elseif a:what == 'commentmiddle'
	let regex = handleWhitespace . b:ECidentFront
		    \ . b:ECprettyComments
    elseif a:what == 'commentend'
	let regex = b:ECprettyComments . b:ECidentBack . a:1
    elseif a:what == 'decommentstart'
		\ || a:what == 'decommentmiddle'
		\ || a:what == 'decommentend'
	let regex = handleWhitespace
    endif

    return regex
endfunction

"
"
" DecideWhatToDo(lineString, commentStart, ...)
"	lineString	-- first line of block
"	commentStart	-- comment start symbol
"	a:1		-- comment end symbol
"
function s:DecideWhatToDo(lineString, commentStart, ...)
    " If we checked already, we return our previous result.
    if !s:firstOfBlock
		\ && (s:Action == 'first'
		\	|| (b:ECuseMPBlock && s:inBlock && a:0))
	return s:blockAction
    endif

    let s:blockAction = 'comment'

    if s:inBlock && a:0 && b:ECuseMPBlock
	let first = getline(s:startBlock)
	let last = getline(s:endBlock)

	if first =~ s:LookFor('checkstart', a:commentStart)
		\ && first !~ s:LookFor('checkend', a:1)
		\ && last !~ s:LookFor('checkstart', a:commentStart)
		\ && last =~ s:LookFor('checkend', a:1)
	    let s:blockAction = 'decomment'
	endif

	return s:blockAction
    endif

    if a:lineString =~ s:LookFor('checkstart', a:commentStart)
	let s:blockAction = 'decomment'
    endif

    if a:0
	if a:lineString !~ s:LookFor('checkend', a:1)
	    let s:blockAction = 'comment'
	endif
    endif

    let s:firstOfBlock = 0
    return s:blockAction
endfunction

"
" TabsToSpaces(str)
"	str	    -- string to convert
"
" Convert leading tabs of given string to spaces.
"
function s:TabsToSpaces(str)
    let string = a:str

    " FIXME: Can we use something like retab? I don't think so,
    " because retab changes every whitespace in the line, but we
    " wan't to modify only the leading spaces. Is this a problem?
    while string =~ '^\( *\)\t'
	let string = substitute(string, '^\( *\)\t', '\1'. s:tabConvert, "")
    endwhile

    return string
endfunction

"
" SpacesToTabs(str)
"	str	    -- string to convert
"
" Convert leading spaces of given string to tabs.
"
function s:SpacesToTabs(str)
    let string = a:str

    if !&expandtab
	while string =~ '^\(\t*\)'. s:tabConvert
	    let string = substitute(string, '^\(\t*\)'. s:tabConvert,
			\ '\1\t', "")
	endwhile
    endif

    return string
endfunction

"
" EnhCommentifyFallback4Embedded(test, fallback)
"	test	    -- test for the special case
"	fallback    -- filetype instead of normal fallback
"
" This function is global. It should be called from filetype
" plugins like php, where the normal fallback behaviour may
" not work. One may use 'synFiletype' to reference the guessed
" filetype via synID.
"
function EnhCommentifyFallback4Embedded(test, fallback)
    let b:EnhCommentifyFallbackTest = a:test
    let b:EnhCommentifyFallbackValue = a:fallback
endfunction

"
" Keyboard mappings.
"
noremap <Plug>Comment
	    \ :call EnhancedCommentify('', 'comment')<CR>
noremap <Plug>DeComment
	    \ :call EnhancedCommentify('', 'decomment')<CR>
noremap <Plug>Traditional
	    \ :call EnhancedCommentify('', 'guess')<CR>
noremap <Plug>FirstLine
	    \ :call EnhancedCommentify('', 'first')<CR>

noremap <Plug>VisualComment
	    \ <Esc>:call EnhancedCommentify('', 'comment',
	    \				    line("'<"), line("'>"))<CR>
noremap <Plug>VisualDeComment
	    \ <Esc>:call EnhancedCommentify('', 'decomment',
	    \				    line("'<"), line("'>"))<CR>
noremap <Plug>VisualTraditional
	    \ <Esc>:call EnhancedCommentify('', 'guess',
	    \				    line("'<"), line("'>"))<CR>
noremap <Plug>VisualFirstLine
	    \ <Esc>:call EnhancedCommentify('', 'first',
	    \				    line("'<"), line("'>"))<CR>
"
" Finally set keybindings.
"
" SetKeybindings(where)
"	where	    -- "l" for local to the buffer, "g" for global
"
function s:SetKeybindings(where)
    if a:where == "l"
	let where = "<buffer>"
	let ns = "b"
    else
	let where = ""
	let ns = "s"
    endif

    execute "let userBindings = ". ns .":ECuserBindings"
    execute "let useAltKeys = ". ns .":ECuseAltKeys"
    execute "let traditionalMode = ". ns .":ECtraditionalMode"
    execute "let firstLineMode = ". ns .":ECfirstLineMode"
    execute "let bindInNormal = ". ns .":ECbindInNormal"
    execute "let bindInInsert = ". ns .":ECbindInInsert"
    execute "let bindInVisual = ". ns .":ECbindInVisual"

    if userBindings
	"
	" *** Put your personal bindings here! ***
	"
    else
	if useAltKeys
	    let s:c = '<M-c>'
	    let s:x = '<M-x>'
	    let s:C = '<M-v>'
	    let s:X = '<M-y>'
	else
	    let s:c = '<Leader>c'
	    let s:x = '<Leader>x'
	    let s:C = '<Leader>C'
	    let s:X = '<Leader>X'
	endif

	if traditionalMode
	    let s:Method = 'Traditional'
	elseif firstLineMode
	    let s:Method = 'FirstLine'
	else
	    let s:Method = 'Comment'

	    " Decomment must be defined here. Everything else is mapped below.
	    if bindInNormal 
		execute 'nmap '. where .' <silent> <unique> '. s:C
			    \ .' <Plug>DeCommentj'
		execute 'nmap '. where .' <silent> <unique> '. s:X
			    \ .' <Plug>DeComment'
	    endif

	    if bindInInsert
		execute 'imap '. where .' <silent> <unique> '. s:C
			    \ .' <Esc><Plug>DeCommentji'
		execute 'imap '. where .' <silent> <unique> '. s:X
			    \ .' <Esc><Plug>DeCommenti'
	    endif

	    if bindInVisual
		execute 'vmap '. where .' <silent> <unique> '. s:C
			    \ .' <Plug>VisualDeCommentj'
		execute 'vmap '. where .' <silent> <unique> '. s:X
			    \ .' <Plug>VisualDeComment'
	    endif
	endif

	if bindInNormal
	    execute 'nmap '. where .' <silent> <unique> '. s:c
			\ .' <Plug>'. s:Method .'j'
	    execute 'nmap '. where .' <silent> <unique> '. s:x
			\ .' <Plug>'. s:Method
	endif

	if bindInInsert
	    execute 'imap '. where .' <silent> <unique> '. s:c
			\ .' <Esc><Plug>'. s:Method .'ji'
	    execute 'imap '. where .' <silent> <unique> '. s:x
			\ .' <Esc><Plug>'. s:Method
	endif

	if bindInVisual
	    execute 'vmap <silent> <unique> '. s:c
			\ .' <Plug>Visual'. s:Method .'j'
	    execute 'vmap '. where .' <silent> <unique> '. s:x
			\ .' <Plug>Visual'. s:Method
	endif
    endif
endfunction

if !s:ECbindPerBuffer
    call s:SetKeybindings("g")
endif

let &cpo = s:savedCpo

" vim: set sts=4 sw=4 ts=8 :
