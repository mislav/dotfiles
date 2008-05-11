" Vim syntax file
" Language: Sass (Syntactically Awesome StyleSheets) 
" Maintainer: Dmitry A. Ilyashevich <dmitry.ilyashevich@gmail.com>
" License: This file can be redistribued and/or modified under the same terms
"   as Vim itself.
"
" Version: 0.1
" Last Change: 2007-08-04
" Notes: Last synced with Haml 1.7
"   Based on css.vim
" TODO: tag names, attributes and values control

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = 'sass'
endif

syn region  sassAttributes         start="^\s*:[a-zA-Z0-9\-_]\+" end="$" oneline keepend contains=sassAttributesIncluded,sassValue,sassConstantIncluded,sassColour,sassValueInteger,sassValueNumber,sassValueLength,sassValueAngle,sassValueTime,sassValueFrequency
syn match   sassAttributesIncluded contained ":[a-zA-Z0-9\-_]\+"

syn region  sassConstant           start="^\s*![a-zA-Z0-9\-_]\+" end="$" oneline keepend contains=sassConstantIncluded,sassColour,sassStringQQ,sassStringQ,sassValueInteger,sassValueNumber,sassValueLength,sassValueAngle,sassValueTime,sassValueFrequency
syn match   sassConstantIncluded   contained "![a-zA-Z0-9\-_]\+"

syn match   sassColour             contained "#[0-9a-fA-F]\{3\}" 
syn match   sassColour             contained "#[0-9a-fA-F]\{6\}"

syn match   sassValue              contained " [a-zA-Z0-9-_\"]\+" contains=sassStringQQ,sassStringQ

syn region  sassSelector           start="^\s*[\.\#]\{0,1\}[a-zA-Z0-9\-_]\+" end="$" oneline keepend contains=sassSelectorIncluded
syn match   sassSelectorIncluded   contained "[\.\#][a-zA-Z0-9\-_]\+"

syn match   sassValueInteger     contained "[-+]\=\d\+"
syn match   sassValueNumber      contained "[-+]\=\d\+\(\.\d*\)\="
syn match   sassValueLength      contained "[-+]\=\d\+\(\.\d*\)\=\(%\|mm\|cm\|in\|pt\|pc\|em\|ex\|px\)"
syn match   sassValueAngle       contained "[-+]\=\d\+\(\.\d*\)\=\(deg\|grad\|rad\)"
syn match   sassValueTime        contained "+\=\d\+\(\.\d*\)\=\(ms\|s\)"
syn match   sassValueFrequency   contained "+\=\d\+\(\.\d*\)\=\(Hz\|kHz\)"

syn match   sassUnicodeEscape    "\\\x\{1,6}\s\?"
syn match   sassSpecialCharQQ    contained +\\"+
syn match   sassSpecialCharQ     contained +\\'+
syn region  sassStringQQ         start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=sassUnicodeEscape,sassSpecialCharQQ
syn region  sassStringQ          start=+'+ skip=+\\\\\|\\'+ end=+'+ contains=sassUnicodeEscape,sassSpecialCharQ

syn match   sassComment	         "\s*//.*$" contains=@Spell,sassTodo
syn keyword sassTodo             TODO FIXME XXX contained

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_haml_syntax_inits")
  if version < 508
    let did_haml_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink sassSelector           Statement
  HiLink sassSelectorIncluded   Statement
  HiLink sassAttributesIncluded Type
  HiLink sassValue              Normal

  HiLink sassConstantIncluded   Constant
"  HiLink sassConstant           Constant
  HiLink sassColour             Constant
  HiLink sassNumber             Number

  HiLink sassStringQQ           sassStringQ
  HiLink sassStringQ            String
  HiLink sassUnicodeEscape      sassSpecialCharQ
  HiLink sassSpecialCharQQ      sassSpecialCharQ
  HiLink sassSpecialCharQ       String

  HiLink sassComment		Comment
  HiLink sassTodo               Todo

  delcommand HiLink
endif
let b:current_syntax = "sass"

if main_syntax == 'sass'
  unlet main_syntax
endif

" vim: nowrap sw=2 sts=2 ts=8 ff=unix:
