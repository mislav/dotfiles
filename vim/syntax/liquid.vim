" liquid.vim: Vim syntax file for Liquid Templates
" Language:	Liquid
" Maintainer:	Eugen Minciu <minciue@gmail.com>
" Last Change: 2006 July 31
" Version: 0.1
" A great deal of thanks to Tim Pope who has been very helpful with my
" noobness. Thank you Tim!
"
" Modelled after eruby.vim written by Michael Brailsford. Thank you Michael.
" Enjoy ;)

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

ru! syntax/html.vim

"set ft=html
unlet b:current_syntax 

" The Liquid Tags
syn keyword liquidKeyword assign capture case cycle else endcase endfor endif for if in include unless when with contained

" These are filters that are made available inside a for loop
syn keyword liquidSpecial forloop length index index0 rindex rindex0 size downcase upcase capitalize truncate truncatewords strip_html join sort date first last size contained

" These are the operators Liquid supports.
syn match liquidEqual "==" contained
syn match liquidNotEqual "!=" contained
syn match liquidLess "<" contained
syn match liquidMore ">" contained
syn match liquidLessOrEqual "<=" contained
syn match liquidMoreOrEqual ">=" contained


" Pipes:
syn match liquidPipe '|' contained

" Strings:
syn region liquidString matchgroup=liquidSpecial start=+"+ skip=/\\"/ end=+"+ contained
syn region liquidString matchgroup=liquidSpecial start=+'+ skip=/\\'/ end=+'+ contained

" Numbers:
syn match liquidNumber "-\=\<\d*\.\=[0-9_]\>" contained

syn match liquidRubyInstanceVariable "@\l\w*" contained


" Output:

syn region liquidTags matchgroup=liquidDelim start='{%' keepend end='%}' contains=liquidRubyInstanceVariable,liquidKeyword,liquidSpecial,liquidString,liquidPipe,liquidNumber,liquidEqual,liquidNotEqual,liquidLess,liquidMore,liquidLessOrEqual,liquidMoreOrEqual 
syn region liquidOutput matchgroup=liquidDelim start='{{' end='}}' 

" Comments:
syn region liquidComment start="{%\s\+comment\s\+%}" end="{%\s\+endcomment\s\+%}"

hi link liquidComment Comment
hi link liquidNumber Number
hi link liquidString String

hi link liquidKeyword Keyword 
hi link liquidPipe Operator 
hi link liquidSpecial Special
hi link liquidEqual Operator
hi link liquidNotEqual Operator
hi link liquidLess Operator
hi link liquidMore Operator 
hi link liquidLessOrEqual Operator 
hi link liquidMoreOrEqual Operator 
hi link liquidRubyInstanceVariable Identifier

hi link liquidDelim Special

let b:current_syntax="liquid"
