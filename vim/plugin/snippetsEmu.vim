"        File: snippetsEmu.vim
"      Author: Felix Ingram
"              ( f.ingram.lists <AT> gmail.com )
" Description: An attempt to implement TextMate style Snippets. Features include
"              automatic cursor placement and command execution.
" $LastChangedDate: 2007-04-05 15:23:48 +0100 (Thu, 05 Apr 2007) $
" Version:     1.1
" $Revision: 109 $
"
" This file contains some simple functions that attempt to emulate some of the 
" behaviour of 'Snippets' from the OS X editor TextMate, in particular the
" variable bouncing and replacement behaviour.
"
" {{{ USAGE:
"
" Place the file in your plugin directory.
" Define snippets using the Snippet command.
" Snippets are best defined in the 'after' subdirectory of your Vim home
" directory ('~/.vim/after' on Unix). Filetype specific snippets can be defined
" in '~/.vim/after/ftplugin/<filetype>_snippets.vim. Using the <buffer> argument will
" By default snippets are buffer specific. To define general snippets available
" globally use the 'Iabbr' command.
"
" Example One:
" Snippet fori for <{datum}> in <{data}>:<CR><{datum}>.<{}>
"
" The above will expand to the following (indenting may differ):
" 
" for <{datum}> in <{data}>:
"   <{datum}>.<{}>
" 
" The cursor will be placed after the first '<{' in insert mode.
" Pressing <Tab> will 'tab' to the next place marker (<{data}>) in
" insert mode.  Adding text between <{ and }> and then hitting <{Tab}> will
" remove the angle brackets and replace all markers with a similar identifier.
"
" Example Two:
" With the cursor at the pipe, hitting <Tab> will replace:
" for <{MyVariableName|datum}> in <{data}>:
"   <{datum}>.<{}>
"
" with (the pipe shows the cursor placement):
"
" for MyVariableName in <{data}>:
"   MyVariableName.<{}>
" 
" Enjoy.
"
" For more information please see the documentation accompanying this plugin.
"
" Additional Features:
"
" Commands in tags. Anything after a ':' in a tag will be run with Vim's
" 'execute' command. The value entered by the user (or the tag name if no change
" has been made) is passed in the @z register (the original contents of the
" register are restored once the command has been run).
"
" Named Tags. Naming a tag (the <{datum}> tag in the example above) and changing
" the value will cause all other tags with the same name to be changed to the
" same value (as illustrated in the above example). Not changing the value and
" hitting <Tab> will cause the tag's name to be used as the default value.
"
" Test tags for pattern matching:
" The following are examples of valid and invalid tags. Whitespace can only be
" used in a tag name if the name is enclosed in quotes.
"
" Valid tags
" <{}>
" <{tagName}>
" <{tagName:command}>
" <{"Tag Name"}>
" <{"Tag Name":command}>
"
" Invalid tags, random text
" <{:}>
" <{:command}>
" <{Tag Name}>
" <{Tag Name:command}>
" <{"Tag Name":}>
" <{Tag }>
" <{OpenTag
"
" Here's our magic search term (assumes '<{',':' and '}>' as our tag delimiters:
" <{\([^[:punct:] \t]\{-}\|".\{-}"\)\(:[^}>]\{-1,}\)\?}>
" }}}

if v:version < 700
  echomsg "snippetsEmu plugin requires Vim version 7 or later"
  finish
endif

if globpath(&rtp, 'plugin/snippetEmu.vim') != ""
  call confirm("It looks like you've got an old version of snippetsEmu installed. Please delete the file 'snippetEmu.vim' from the plugin directory. Note lack of 's'")
endif

let s:debug = 0

function! <SID>Debug(text)
  if exists('s:debug') && s:debug == 1
    echom a:text
  endif
endfunction

if (exists('loaded_snippet') || &cp) && !s:debug
  finish
endif

call <SID>Debug("Snippy: Started the plugin")

let loaded_snippet=1
" {{{ Set up variables
if !exists("g:snip_start_tag")
    let g:snip_start_tag = "<{"
endif

if !exists("g:snip_end_tag")
    let g:snip_end_tag = "}>"
endif

if !exists("g:snip_elem_delim")
    let g:snip_elem_delim = ":"
endif

call <SID>Debug("Snippy: Set variables")

let s:just_expanded = 0

" }}}
" {{{ Set up menu
for def_file in split(globpath(&rtp, "after/ftplugin/*_snippets.vim"), '\n')
  call <SID>Debug("Snippy: Adding ".def_file." definitions to menu")
  let snip = substitute(def_file, '.*[\\/]\(.*\)_snippets.vim', '\1', '')
  exec "nmenu <silent> S&nippets.".snip." :source ".def_file."<CR>"
endfor
" }}}
" {{{ Map Jumper to the default key if not set already
function! <SID>GetSuperTabSNR()
  let a_sav = @a
  redir @a
  exec "silent function"
  redir END
  let funclist = @a
  let @a = a_sav
  let func = split(split(matchstr(funclist,'.SNR.\{-}SuperTab(command)'),'\n')[-1])[1]
  return matchlist(func, '\(.*\)S')[1]
endfunction

if ( !hasmapto( '<Plug>Jumper', 'i' ) )
  if globpath(&rtp, 'plugin/supertab.vim') != ""
    call <SID>Debug("Snippy: SuperTab installed")
    let s:supInstalled = 1
    let s:done_remap = 0
    imap <Tab> <Plug>Jumper
  else
    let s:supInstalled = 0
    imap <unique> <Tab> <Plug>Jumper
  endif
else
  let s:supInstalled = 0
endif
if ( !hasmapto( 'i<BS><Tab>', 's' ) )
  smap <unique> <Tab> i<BS><Tab>
endif
imap <silent> <script> <Plug>Jumper <C-R>=<SID>Jumper()<CR>

call <SID>Debug("Snippy: Mapped keys")

" }}}
" {{{ SetLocalTagVars()
function! <SID>SetLocalTagVars()
  if exists("b:snip_end_tag") && exists("b:snip_start_tag") && exists("b:snip_elem_delim")
    return [b:snip_start_tag, b:snip_elem_delim, b:snip_end_tag]
  else
    return [g:snip_start_tag, g:snip_elem_delim, g:snip_end_tag]
  endif
endfunction
" }}}
" {{{ CheckForBufferTags() - Checks to see whether buffer specific tags have
" been defined
function! <SID>CheckForBufferTags()
  if exists("b:snip_end_tag") && exists("b:snip_start_tag") && exists("b:snip_elem_delim")
    return 1
  else
    return 0
  endif
endfunction
" }}}
" {{{ SetSearchStrings() - Set the search string. Checks for buffer dependence
function! <SID>SetSearchStrings()
  let [snip_start_tag, snip_elem_delim, snip_end_tag] = <SID>SetLocalTagVars()
  let b:search_str = snip_start_tag.'\([^'.
        \snip_start_tag.snip_end_tag.
        \'[:punct:] \t]\{-}\|".\{-}"\)\('.
        \snip_elem_delim.
        \'[^'.snip_end_tag.snip_start_tag.']\{-1,}\)\?'.snip_end_tag
  let b:search_commandVal = "[^".snip_elem_delim."]*"
  let b:search_endVal = "[^".snip_end_tag."]*"
endfunction
" }}}
" {{{ SetKeywords(text) - Add characters to the current buffer's iskeywords
" Refactored out here as it's used twice in SetCom
function! <SID>SetKeywords(text)
  if <SID>CheckForBufferTags()
    let snip_start_tag = b:snip_start_tag
  else
    let snip_start_tag = g:snip_start_tag
  endif
  let tokens = split(a:text, ' ')
  let lhs = tokens[0]
  let rhs = join(tokens[1:])
  call <SID>SetSearchStrings()
  for char in split(lhs, '\zs')
    if char == '@'
      exec 'setlocal iskeyword+=@-@'
    elseif char != '^'
      try
        exec 'setlocal iskeyword+='.char
      catch /474/
      endtry
    endif
    if stridx(snip_start_tag, char) != -1
      echom "One of the snippet definitions contains a character in your snip_start_tag; this could cause problems"
    endif
  endfor
  return [<SID>Hash(lhs), rhs]
endfunction
" }}}
" {{{ SetCom(text) - Set command function
function! <SID>SetCom(text)
  let text = substitute(a:text, '\c<CR>\|<Esc>\|<Tab>\|<BS>\|<Space>\|<C-r>\|<Pipe>\|\"\|\\','\\&',"g")

  if s:supInstalled == 1 && s:done_remap == 0
    let s:SupSNR = <SID>GetSuperTabSNR()
    imap <Tab> <Plug>Jumper
    let s:done_remap = 1
  endif

  let text = substitute(text, "$", "","")
  if match(text,"<buffer>") == 0
    let text = substitute(text, '\s*<buffer>\s*', "","")
    let [lhs, rhs] = <SID>SetKeywords(text)
    return "let b:snip_".lhs.' = "'.rhs.'"'
  else
    let text = substitute(text, '^\s*', "", "")
    let [lhs, rhs] = <SID>SetKeywords(text)
    return "let g:snip_".lhs.' = "'.rhs.'"'
  endif
endfunction
" }}}
" {{{ Check for end - Check whether the cursor is at the end of the current line
function! <SID>CheckForEnd()
  " Check to see whether we're at the end of a line so we can decide on
  " how to start inserting
  let [snip_start_tag, snip_elem_delim, snip_end_tag] = <SID>SetLocalTagVars()
  if col(".") == <SID>StrLen(getline("."))
    return 1
  elseif getline(".") =~ '^$'
    return 1
  elseif (getline(".")[col(".")] == snip_elem_delim) &&
      \(getline(".")[col(".") + 1] == snip_end_tag) &&
      \(col(".") + 2 == <SID>StrLen(getline(".")))
      return 1
  else
    return 0 
  endif
endfunction
" }}}
" {{{ RestoreSearch()
" Checks whether more tags exist and restores hlsearch and @/ if not
function! <SID>RestoreSearch()
  if !search(b:search_str, "n")
    if exists("b:hl_on") && b:hl_on == 1
      setlocal hlsearch
    endif
    if exists("b:search_sav")
      let @/ = b:search_sav
    endif
  endif
endfunction
"}}}
" {{{ DeleteEmptyTag 
function! <SID>DeleteEmptyTag()
  let [snip_start_tag, snip_elem_delim, snip_end_tag] = <SID>SetLocalTagVars()
  for i in range(<SID>StrLen(snip_start_tag) + <SID>StrLen(snip_end_tag))
    normal x
  endfor
endfunction
" }}}
" {{{ SetUpTags()
function! <SID>SetUpTags()
  call <SID>Debug("Snippy: ---- Start of SetUpTags() ----")
  let [snip_start_tag, snip_elem_delim, snip_end_tag] = <SID>SetLocalTagVars()
  if (strpart(getline("."), col(".")+strlen(snip_start_tag)-1, strlen(snip_end_tag)) == snip_end_tag)
    call <SID>Debug("Snippy: Found an empty tag")
    let b:tag_name = ""
    if col(".") + <SID>StrLen(snip_start_tag.snip_end_tag) == <SID>StrLen(getline("."))
      call <SID>DeleteEmptyTag()
      call <SID>RestoreSearch()
      if col(".") == <SID>StrLen(getline("."))
        return "\<Esc>a"
      else
        return ''
      endif
    else
      call <SID>DeleteEmptyTag()
      call <SID>RestoreSearch()
      if col(".") == <SID>StrLen(getline("."))
        return "\<Esc>A"
      else
        return ''
      endif
    endif
    return ''
  else
    " Not on an empty tag so it must be a normal tag
    let b:tag_name = <SID>ChopTags(matchstr(getline("."),b:search_str,col(".")-1))
    call <SID>Debug("Snippy: On a tag called: ".b:tag_name)
    let start_skip = ""
"    Check for exclusive selection mode. If exclusive is not set then we need to
"    move back a character.
    if &selection == "exclusive"
      let end_skip = ""
    else
      let end_skip = "h"
    endif
"    let start_skip = string(<SID>StrLen(snip_start_tag))."l"
    for i in range(<SID>StrLen(snip_start_tag)+1)
      let start_skip = start_skip."l"
    endfor
    call <SID>Debug("Snippy: Start skip is: ".start_skip)
    call <SID>Debug("Snippy: Col() is: ".col("."))
    if col(".") <= <SID>StrLen(snip_start_tag)
      call <SID>Debug("Snippy: We're at the start of the line so don't need to skip the first char of start tag")
"      let start_skip = strpart(start_skip, <SID>StrLen(start_skip)-1)
      let start_skip = strpart(start_skip, 0, strlen(start_skip)-1)
      call <SID>Debug("Snippy: Start skip is now: ".start_skip)
    endif
"    for i in range(strlen(snip_end_tag)-1)
"      let end_skip = end_skip."h"
"    endfor
    call <SID>Debug("Snippy: ---- End of SetUpTags() ----")
    return "\<Esc>".start_skip."v/".snip_end_tag."\<CR>".end_skip."\<C-g>"
  endif
endfunction
" }}}
" {{{ NextHop() - Jump to the next tag if one is available
function! <SID>NextHop()
  call <SID>Debug("Snippy: ---------------- Start of NextHop ----------------")
  let [snip_start_tag, snip_elem_delim, snip_end_tag] = <SID>SetLocalTagVars()
  if s:just_expanded == 1
    call cursor(s:curLine, 1)
    let s:just_expanded = 0
  else
    call cursor(s:curLine, s:curCurs-1)
  endif
  " Check to see whether we're sitting on a tag and if not then perform a
  " search
  call <SID>Debug("Snippy: Col() is: ".col("."))
  call <SID>Debug("Snippy: Position of next match = ".match(getline("."), b:search_str))
  " If the first match is after the current cursor position or not on this
  " line...
  if match(getline("."), b:search_str) >= col(".") || match(getline("."), b:search_str) == -1
    " Perform a search to jump to the next tag
    call <SID>Debug("Snippy: Seaching for a tag")
    if search(b:search_str) != 0
      return <SID>SetUpTags()
    else
      " there are no more matches
      call <SID>Debug("Snippy: No more tags in the buffer")
      " Restore hlsarch and @/
      call <SID>RestoreSearch()
      return ''
    endif
  else
    " The match on the current line is on or before the cursor, so we need to
    " move the cursor back
    call <SID>Debug("Snippy: Moving the cursor back")
    call <SID>Debug("Snippy: Col is: ".col("."))
    call <SID>Debug("Snippy: Match is: ".match(getline("."), b:search_str))
    while col(".") > match(getline("."), b:search_str) + 1
      normal h
    endwhile
    call <SID>Debug("Snippy: Col is: ".col("."))
    " Now we just set up the tag as usual
    return <SID>SetUpTags()
  endif
"  return ''
endfunction
" }}}
" {{{ RunCommand() - Execute commands stored in tags
function! <SID>RunCommand(command, z)
  " Escape backslashes for the matching.  Not sure what other escaping is
  " needed here
  call <SID>Debug("Snippy: ---- Start of RunCommand ----")
  let [snip_start_tag, snip_elem_delim, snip_end_tag] = <SID>SetLocalTagVars()
  call <SID>Debug("Snippy: RunCommand was passed this command: ".a:command." and this value: ".a:z)
  let command = a:command
  if command == ''
    return a:z
  endif
  let s:snip_temp = substitute(command, "\\", "\\\\\\\\","g")
  " Save current value of 'z'
  let s:snip_save = @z
  let @z=a:z
  " Call the command
  execute 'let @z = '. a:command
  " Replace the value
  let ret = @z
  let @z = s:snip_save
  call <SID>Debug("Snippy: ---- End of RunCommand ----")
  return ret
endfunction
" }}}
" {{{ MakeChanges() - Search the document making all the changes required
" This function has been factored out to allow the addition of commands in tags
function! <SID>MakeChanges()
  " Make all the changes
  " Change all the tags with the same name and no commands defined
  call <SID>Debug("Snippy: ---------------- Start of MakeChanges() ----------------")
  let [snip_start_tag, snip_elem_delim, snip_end_tag] = <SID>SetLocalTagVars()

  if b:tag_name == ""
    call <SID>Debug("Snippy: Nothing to do: tag_name is empty")
    call <SID>Debug("Snippy: ---------------- End of MakeChanges() ----------------")
    return
  endif
  let matchVal = snip_start_tag.b:tag_name.snip_end_tag
  let tagmatch = '\V'.matchVal
  call <SID>Debug("Snippy: Matching on this value: ".matchVal)
  call <SID>Debug("Snippy: Replacing with this value: ".s:replaceVal)
  try
    call <SID>Debug("Snippy: Running these commands: ".join(b:command_dict[b:tag_name], "', '"))
  catch /E175/
    call <SID>Debug("Snippy: Could not find this key in the dict: ".b:tag_name)
  endtry
  let ind = 0
  while search(matchVal,"w") > 0
    try
      let commandResult = <SID>RunCommand(b:command_dict[b:tag_name][0], s:replaceVal)
    catch /E175/
      call <SID>Debug("Snippy: Could not find this key in the dict: ".b:tag_name)
    endtry
    call <SID>Debug("Snippy: Got this result: ".commandResult)
    let lines = split(substitute(getline("."), tagmatch, commandResult, "g"),'\n')
    if len(lines) > 1
      call setline(".", lines[0])
      call append(".", lines[1:])
    else
      call setline(".", lines)
    endif
    try
      unlet b:command_dict[b:tag_name][0]
    catch /E175/
      call <SID>Debug("Snippy: Could not find this key in the dict: ".b:tag_name)
    endtry
  endwhile
  call <SID>Debug("Snippy: ---------------- End of MakeChanges() ----------------")
endfunction

" }}}
" {{{ ChangeVals() - Set up values for MakeChanges()
function! <SID>ChangeVals(changed)
  call <SID>Debug("Snippy: ---------------- Start of ChangeVals() ----------------")
  if a:changed == 1
    let s:CHANGED_VAL = 1
  else
    let s:CHANGED_VAL = 0
  endif
  call <SID>Debug("Snippy: CHANGED_VAL: ".s:CHANGED_VAL)
  let [snip_start_tag, snip_elem_delim, snip_end_tag] = <SID>SetLocalTagVars()
  call <SID>Debug("Snippy: b:tag_name: ".b:tag_name)
  let elem_match = match(s:line, snip_elem_delim, s:curCurs)
  let tagstart = strridx(getline("."), snip_start_tag,s:curCurs)+strlen(snip_start_tag)
  call <SID>Debug("Snippy: About to access b:command_dict")
  try
    let commandToRun = b:command_dict[b:tag_name][0]
    call <SID>Debug("Snippy: Accessed command_dicT")
    call <SID>Debug("Snippy: Running this command: ".commandToRun)
    unlet b:command_dict[b:tag_name][0]
    call <SID>Debug("Snippy: Command list is now: ".join(b:command_dict[b:tag_name], "', '"))
  catch /E175/
    call <SID>Debug("Snippy: Could not find this key in the dict: ".b:tag_name)
  endtry
  let commandMatch = substitute(commandToRun, '\', '\\\\', "g")
  if s:CHANGED_VAL
    " The value has changed so we need to grab our current position back
    " to the start of the tag
    let replaceVal = strpart(getline("."), tagstart,s:curCurs-tagstart)
    call <SID>Debug("Snippy: User entered this value: ".replaceVal)
    let tagmatch = replaceVal
    call <SID>Debug("Snippy: Col is: ".col("."))
    exec "normal ".<SID>StrLen(tagmatch)."h"
    call <SID>Debug("Snippy: Col is: ".col("."))
  else
    " The value hasn't changed so it's just the tag name
    " without any quotes that are around it
    call <SID>Debug("Snippy: Tag name is: ".b:tag_name)
    let replaceVal = substitute(b:tag_name, '^"\(.*\)"$', '\1', '')
"    let replaceVal = substitute(b:tag_name, '^\"\(.*\)\"$', "\1", "")
    call <SID>Debug("Snippy: User did not enter a value. Replacing with this value: ".replaceVal)
    let tagmatch = ''
    call <SID>Debug("Snippy: Col is: ".col("."))
  endif
  let tagmatch = '\V'.snip_start_tag.tagmatch.snip_end_tag
  call <SID>Debug("Snippy: Matching on this string: ".tagmatch)
  let tagsubstitution = <SID>RunCommand(commandToRun, replaceVal)
  let lines = split(substitute(getline("."), tagmatch, tagsubstitution, ""),'\n')
  if len(lines) > 1
    call setline(".", lines[0])
    call append(".", lines[1:])
  else
    call setline(".", lines)
  endif
  " We use replaceVal instead of tagsubsitution as otherwise the command
  " result will be passed to subsequent tags
  let s:replaceVal = replaceVal
  call <SID>MakeChanges()
  unlet s:CHANGED_VAL
  call <SID>Debug("Snippy: ---------------- End of ChangeVals() ----------------")
endfunction
" }}}
"{{{ SID() - Get the SID for the current script
function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfun
"}}}
"{{{ CheckForInTag() - Check whether we're in a tag
function! <SID>CheckForInTag()
  let [snip_start_tag, snip_elem_delim, snip_end_tag] = <SID>SetLocalTagVars()
  if snip_start_tag != snip_end_tag
    " The tags are different so we can check to see whether the
    " end tag comes before a start tag
    let s:endMatch = match(s:line, snip_end_tag, s:curCurs)
    let s:startMatch = match(s:line, snip_start_tag, s:curCurs)
    let s:whiteSpace = match(s:line, '\s', s:curCurs)

    if s:endMatch != -1 && ((s:endMatch < s:startMatch) || s:startMatch == -1)
      " End has come before start so we're in a tag.
      return 1
    else
      return 0
    endif
  else
    " Start and end tags are the same so we need do tag counting to see
    " whether we're in a tag.
    let s:count = 0
    let s:curSkip = s:curCurs
    while match(strpart(s:line,s:curSkip),snip_start_tag) != -1 
      if match(strpart(s:line,s:curSkip),snip_start_tag) == 0
        let s:curSkip = s:curSkip + 1
      else
        let s:curSkip = s:curSkip + 1 + match(strpart(s:line,s:curSkip),snip_start_tag)
      endif
      let s:count = s:count + 1
    endwhile
    if (s:count % 2) == 1
      " Odd number of tags implies we're inside a tag.
      return 1
    else
      " We're not inside a tag.
      return 0
    endif
  endif
endfunction
"}}}
" {{{ <SID>SubSpecialVars(text)
function! <SID>SubSpecialVars(text)
  let text = a:text
  let text = substitute(text, 'SNIP_FILE_NAME', expand('%'), 'g')
  let text = substitute(text, 'SNIP_ISO_DATE', strftime("%Y-%m-%d"), 'g')
  return text
endfunction
" }}}
" {{{ <SID>SubCommandOutput(text)
function! <SID>SubCommandOutput(text)
  call <SID>Debug("Snippy: ----- Start of SubCommandOutput -----")
  let search = '``.\{-}``'
  let text = a:text
  while match(text, search) != -1
    let command_match = matchstr(text, search)
    call <SID>Debug("Snippy: Command found: ".command_match)
    let command = substitute(command_match, '^..\(.*\)..$', '\1', '')
    call <SID>Debug("Snippy: Command being run: ".command)
    exec 'let output = '.command
    let output = escape(output, '\')
    let text = substitute(text, '\V'.escape(command_match, '\'), output, '')
  endwhile
  let text = substitute(text, '\\`\\`\(.\{-}\)\\`\\`','``\1``','g')
  call <SID>Debug("Snippy: ----- End of SubCommandOutput -----")
  return text
endfunction
" }}}
" {{{ <SID>RemoveAndStoreCommands(text)
function! <SID>RemoveAndStoreCommands(text)
  call <SID>Debug("Snippy: ---------------- Start of RemoveAndStoreCommands ----------------")

  let [snip_start_tag, snip_elem_delim, snip_end_tag] = <SID>SetLocalTagVars()
  let text = a:text
  if !exists("b:command_dict")
    let b:command_dict = {}
  endif
  let tmp_command_dict = {}
"  if s:debug == 1
"    let b:command_dict = {}
"  endif
  let ind = 0
  let ind = match(text, b:search_str)
  while ind > -1
    call <SID>Debug("Snippy: Text is: ".text)
    call <SID>Debug("Snippy: index is: ".ind)
    let tag = matchstr(text, b:search_str, ind)
    call <SID>Debug("Snippy: Tag is: ".tag)
    let commandToRun = matchstr(tag, snip_elem_delim.".*".snip_end_tag)

    if commandToRun != ''
      let tag_name = strpart(tag,strlen(snip_start_tag),match(tag,snip_elem_delim)-strlen(snip_start_tag))
      call <SID>Debug("Snippy: Got this tag: ".tag_name)
      call <SID>Debug("Snippy: Adding this command: ".commandToRun)
      if tag_name != ''
        if has_key(tmp_command_dict, tag_name)
          call add(tmp_command_dict[tag_name], strpart(commandToRun, 1, strlen(commandToRun)-strlen(snip_end_tag)-1))
        else
          let tmp_command_dict[tag_name] = [strpart(commandToRun, 1, strlen(commandToRun)-strlen(snip_end_tag)-1)]
        endif
      endif
      let text = substitute(text, '\V'.escape(commandToRun,'\'), snip_end_tag,'')
    else
      let tag_name = <SID>ChopTags(tag)
      if tag_name != ''
        if has_key(tmp_command_dict, tag_name)
          call add(tmp_command_dict[tag_name], '')
        else
          let tmp_command_dict[tag_name] = ['']
        endif
      endif
    endif
    call <SID>Debug("Snippy: ".tag." found at ".ind)
    let ind = match(text, b:search_str, ind+strlen(snip_end_tag))
  endwhile
  for key in keys(tmp_command_dict)
    if has_key(b:command_dict, key)
      for item in reverse(tmp_command_dict[key])
        call insert(b:command_dict[key], item)
      endfor
    else
      let b:command_dict[key] = tmp_command_dict[key]
    endif
  endfor
  call <SID>Debug("Snippy: ---------------- End of RemoveAndStoreCommands ----------------")
  return text
endfunction
" }}}
" {{{ Jumper()
" We need to rewrite this function to reflect the new behaviour. Every jump
" will now delete the markers so we need to allow for the following conditions
" 1. Empty tags e.g. "<{}>".  When we land inside then we delete the tags.
"  "<{:}>" is now an invalid tag (use "<{}>" instead) so we don't need to check for
"  this
" 2. Tag with variable name.  Save the variable name for the next jump.
" 3. Tag with command. Tags no longer have default values. Everything after the
" centre delimiter until the end tag is assumed to be a command.
" 
" Jumper is performed when we want to perform a jump.  If we've landed in a
" 1. style tag then we'll be in free form text and just want to jump to the
" next tag.  If we're in a 2. or 3. style tag then we need to look for whether
" the value has changed and make all the replacements.   If we're in a 3.
" style tag then we need to replace all the occurrences with their command
" modified values.
" 
function! <SID>Jumper()
  call <SID>Debug("Snippy: ---------------- Start of Jumper ----------------")
  " Set up some useful variables
  let [snip_start_tag, snip_elem_delim, snip_end_tag] = <SID>SetLocalTagVars()

  if s:supInstalled == 1 && s:done_remap == 0
    let s:SupSNR = <SID>GetSuperTabSNR()
    imap <Tab> <Plug>Jumper
    let s:done_remap = 1
  endif

  if !exists('b:search_str')
    call <SID>Debug("Snippy: ---------------- End of Jumper ----------------")
    if s:supInstalled
      return "\<C-R>=".s:SupSNR."SuperTab('n')\<CR>"
    else
      return "\<Tab>"
    endif
  endif
  let s:curCurs = col(".") - 1
  let s:curLine = line(".")
  let s:line = getline(".")
  let s:replaceVal = ""
  " Check to see whether we're at the start of a tag.  
  " start then we should be assuming that we've got a 'default' value or a
  " command to run.  Otherwise the user will have pressed the jump key
  " without changing the value.
  " First we need to check that we're inside a tag i.e. the previous
  " jump didn't land us in a 1. style tag.
   
  " First we'll check that the user hasn't just typed a snippet to expand
  "
  let origword = matchstr(strpart(getline("."), 0, s:curCurs), '\k\{-}$')
  call <SID>Debug("Snippy: Original word was: ".origword)
  let word = <SID>Hash(origword)
"    " The following code is lifted wholesale from the imaps.vim script - Many
"    " thanks for the inspiration to add the TextMate compatibility
"    " Unless we are at the very end of the word, we need to go back in order
"    " to find the last word typed.
  let rhs = ''
  " Check for buffer specific expansions
  if exists('b:snip_'.word)
    exe 'let rhs = b:snip_'.word
  elseif exists('g:snip_'.word)
  " also check for global definitions
    exe 'let rhs = g:snip_'.word
  endif

  if rhs != ''
    " Save the value of hlsearch
    if &hls
      call <SID>Debug("Hlseach set")
      setlocal nohlsearch
      let b:hl_on = 1
    else
      call <SID>Debug("Hlseach not set")
      let b:hl_on = 0
    endif
    " Save the last search value
    let b:search_sav = @/
    " if this is a mapping, then erase the previous part of the map
    " by also returning a number of backspaces.
    let bkspc = substitute(origword, '.', "\<bs>", "g")
    call <SID>Debug("Snippy: Backspacing ".<SID>StrLen(origword)." characters")
    let delEndTag = ""
    if <SID>CheckForInTag()
      call <SID>Debug("Snippy: We're doing a nested tag")
      call <SID>Debug("Snippy: B:tag_name: ".b:tag_name)
      if b:tag_name != ''
        try
          call <SID>Debug("Snippy: Commands for this tag are currently: ".join(b:command_dict[b:tag_name],"', '"))
          call <SID>Debug("Snippy: Removing command for '".b:tag_name."'")
          unlet b:command_dict[b:tag_name][0]
          call <SID>Debug("Snippy: Commands for this tag are now: ".join(b:command_dict[b:tag_name],"', '"))
        catch /E175/
          call <SID>Debug("Snippy: Could not find this key in the dict: ".b:tag_name)
        endtry
      endif
      call <SID>Debug("Snippy: Deleting start tag")
      let bkspc = bkspc.substitute(snip_start_tag, '.', "\<bs>", "g")
      call <SID>Debug("Snippy: Deleting end tag")
      let delEndTag = substitute(snip_end_tag, '.', "\<Del>", "g")
      call <SID>Debug("Snippy: Deleting ".<SID>StrLen(delEndTag)." characters")
    endif
    
    " We've found a mapping so we'll substitute special variables
    let rhs = <SID>SubSpecialVars(rhs)
    let rhs = <SID>SubCommandOutput(rhs)
    " Now we'll chop out the commands from tags
    let rhs = <SID>RemoveAndStoreCommands(rhs)

    " This movement method is from imaps again. It's kinda neat so we'll use it
    " here.
    let initial = "SnipStartSnipStart"

    if &expandtab
        let tabs = indent(".")/&shiftwidth
        let tabstr = repeat(' ',&shiftwidth)
    else
        let tabs = indent(".")/&tabstop
        let tabstr = '\t'
    endif
    let tab_text = repeat(tabstr,tabs)
    let rhs = substitute(rhs, "\<CR>", "&".tab_text,'g')

    call <SID>Debug("Snippy: ---------------- End of Jumper ----------------")
    return "\<Esc>:set paste\<CR>a".bkspc.delEndTag.initial.rhs."\<Esc>:set nopaste\<CR>?".initial."\<CR>".strlen(initial)."xi\<C-r>=<SNR>".s:SID()."_NextHop()\<CR>"
  else
    " No definition so let's check to see whether we're in a tag
    if <SID>CheckForInTag()
      call <SID>Debug("Snippy: No mapping and we're in a tag")
      " We're in a tag so we need to do processing
      if strpart(s:line, s:curCurs - strlen(snip_start_tag), strlen(snip_start_tag)) == snip_start_tag
        call <SID>Debug("Snippy: Value not changed")
        call <SID>ChangeVals(0)
        call <SID>Debug("Snippy: ---------------- End of Jumper ----------------")
        return "\<C-r>=<SNR>".s:SID()."_NextHop()\<CR>"
      else
        call <SID>Debug("Snippy: Value changed")
        call <SID>ChangeVals(1)
        call <SID>Debug("Snippy: ---------------- End of Jumper ----------------")
        return "\<C-r>=<SNR>".s:SID()."_NextHop()\<CR>"
      endif
    else
      " We're not in a tag so we'll see whether there are more tags
      if search(b:search_str, "n")
        " More tags so let's perform nexthop
        let s:replaceVal = ""
        call <SID>Debug("Snippy: ---------------- End of Jumper ----------------")
        return "\<C-r>=<SNR>".s:SID()."_NextHop()\<CR>"
      else
        " No more tags so let's return a Tab after restoring hlsearch and @/
        call <SID>RestoreSearch()

        if exists("b:command_dict")
          unlet b:command_dict
        endif
        if s:supInstalled
          call <SID>Debug('Snippy: SuperTab installed. Returning <C-n> instead of <Tab>')
          call <SID>Debug("Snippy: ---------------- End of Jumper ----------------")
          return "\<C-R>=".s:SupSNR."SuperTab('n')\<CR>"
        else
          call <SID>Debug("Snippy: ---------------- End of Jumper ----------------")
          return "\<Tab>"
        endif
      endif
    endif
  endif
endfunction
" }}}
" {{{ Set up the 'Iabbr' and 'Snippet' commands
command! -nargs=+ Iabbr execute <SID>SetCom(<q-args>)
command! -nargs=+ Snippet execute <SID>SetCom("<buffer> ".<q-args>)
"}}}
" {{{ Utility functions

" This function will just return what's passed to it unless a change has been
" made
fun! D(text)
  if exists('s:CHANGED_VAL') && s:CHANGED_VAL == 1
    return @z
  else
    return a:text
  endif
endfun

" <SID>Hash allows the use of special characters in snippets
" This function is lifted straight from the imaps.vim plugin. Please let me know
" if this is against licensing.
function! <SID>Hash(text)
	return substitute(a:text, '\([^[:alnum:]]\)',
				\ '\="_".char2nr(submatch(1))."_"', 'g')
endfunction

" This function chops tags from any text passed to it
function! <SID>ChopTags(text)
  call <SID>Debug("Snippy: ---------------- Start of ChopTags ----------------")
  let text = a:text
  call <SID>Debug("Snippy: ChopTags was passed this text: ".text)
  let [snip_start_tag, snip_elem_delim, snip_end_tag] = <SID>SetLocalTagVars()
  let text = strpart(text, strlen(snip_start_tag))
  let text = strpart(text, 0, strlen(text)-strlen(snip_end_tag))
  call <SID>Debug("Snippy: ChopTags is returning this text: ".text)
  call <SID>Debug("Snippy: ---------------- End of ChopTags ----------------")
  return text
endfunction

" This function ensures we measure string lengths correctly
function! <SID>StrLen(str)
  call <SID>Debug("Snippy: StrLen returned: ".strlen(substitute(a:str, '.', 'x', 'g'))." based on this text: ".a:str)
  return strlen(substitute(a:str, '.', 'x', 'g'))
endfunction
" }}}
" vim: set tw=80 sw=2 sts=2 et foldmethod=marker :
