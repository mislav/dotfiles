" vim600: set foldmethod=marker:
"
" Vim plugin to assist in working with files under control of CVS or SVN.
"
" Version:       Beta 13
" Maintainer:    Bob Hiestand <bob.hiestand@gmail.com>
" License:
" Copyright (c) 2007 Bob Hiestand
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
" FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
" IN THE SOFTWARE.
"
" Section: Documentation {{{1
"
" Provides functions to invoke various source control commands on the current
" file (either the current buffer, or, in the case of an directory buffer, the
" directory and all subdirectories associated with the current buffer).  The
" output of the commands is captured in a new scratch window.
"
" This plugin needs additional extension plugins, each  specific to a source
" control system, to function.  Those plugins should be placed in a
" subdirectory of the standard plugin directory named 'vcscommand'.  Several
" options include the name of the version control system in the option name.
" Such options use the placeholder text '{VCSType}', which would be replaced
" in actual usage with 'CVS' or 'SVN', for instance.
"
" Command documentation {{{2
"
" VCSAdd           Adds the current file to source control.
"
" VCSAnnotate      Displays the current file with each line annotated with the
"                  version in which it was most recently changed.  If an
"                  argument is given, the argument is used as a revision
"                  number to display.  If not given an argument, it uses the
"                  most recent version of the file on the current branch.
"                  Additionally, if the current buffer is a VCSAnnotate buffer
"                  already, the version number on the current line is used.
"
" VCSCommit[!]     Commits changes to the current file to source control.
"
"                  If called with arguments, the arguments are the log message.
"
"                  If '!' is used, an empty log message is committed.
"
"                  If called with no arguments, this is a two-step command.
"                  The first step opens a buffer to accept a log message.
"                  When that buffer is written, it is automatically closed and
"                  the file is committed using the information from that log
"                  message.  The commit can be abandoned if the log message
"                  buffer is deleted or wiped before being written.
"
" VCSDelete        Deletes the current file and removes it from source control.
"
" VCSDiff          With no arguments, this displays the differences between
"                  the current file and its parent version under source
"                  control in a new scratch buffer.
"
"                  With one argument, the diff is performed on the
"                  current file against the specified revision.
"
"                  With two arguments, the diff is performed between the
"                  specified revisions of the current file.
"
"                  This command uses the 'VCSCommand{VCSType}DiffOpt' variable
"                  to specify diff options.  If that variable does not exist,
"                  a plugin-specific default is used.  If you wish to have no
"                  options, then set it to the empty string.
"
" VCSGotoOriginal  Jumps to the source buffer if the current buffer is a VCS
"                  scratch buffer.  If VCSGotoOriginal[!] is used, remove all
"                  VCS scratch buffers associated with the original file.
"
" VCSInfo          Displays extended information about the current file in a
"                  new scratch buffer. 
"
" VCSLock          Locks the current file in order to prevent other users from
"                  concurrently modifying it.  The exact semantics of this
"                  command depend on the underlying VCS.
"
" VCSLog           Displays the version history of the current file in a new
"                  scratch buffer.
"
" VCSRevert        Replaces the modified version of the current file with the
"                  most recent version from the repository.
"
" VCSReview        Displays a particular version of the current file in a new
"                  scratch buffer.  If no argument is given, the most recent
"                  version of the file on the current branch is retrieved.
"
" VCSStatus        Displays versioning information about the current file in a
"                  new scratch buffer.
"
" VCSUnlock        Unlocks the current file in order to allow other users from
"                  concurrently modifying it.  The exact semantics of this
"                  command depend on the underlying VCS.
"
" VCSUpdate        Updates the current file with any relevant changes from the
"                  repository.
"
" VCSVimDiff       Uses vimdiff to display differences between versions of the
"                  current file.
"
"                  If no revision is specified, the most recent version of the
"                  file on the current branch is used.  With one argument,
"                  that argument is used as the revision as above.  With two
"                  arguments, the differences between the two revisions is
"                  displayed using vimdiff.
"
"                  With either zero or one argument, the original buffer is
"                  used to perform the vimdiff.  When the scratch buffer is
"                  closed, the original buffer will be returned to normal
"                  mode.
"
"                  Once vimdiff mode is started using the above methods,
"                  additional vimdiff buffers may be added by passing a single
"                  version argument to the command.  There may be up to 4
"                  vimdiff buffers total.
"
"                  Using the 2-argument form of the command resets the vimdiff
"                  to only those 2 versions.  Additionally, invoking the
"                  command on a different file will close the previous vimdiff
"                  buffers.
"
" Mapping documentation: {{{2
"
" By default, a mapping is defined for each command.  User-provided mappings
" can be used instead by mapping to <Plug>CommandName, for instance:
"
" nmap ,ca <Plug>VCSAdd
"
" The default mappings are as follow:
"
"   <Leader>ca VCSAdd
"   <Leader>cn VCSAnnotate
"   <Leader>cc VCSCommit
"   <Leader>cD VCSDelete
"   <Leader>cd VCSDiff
"   <Leader>cg VCSGotoOriginal
"   <Leader>cG VCSGotoOriginal!
"   <Leader>ci VCSInfo
"   <Leader>cl VCSLog
"   <Leader>cL VCSLock
"   <Leader>cr VCSReview
"   <Leader>cs VCSStatus
"   <Leader>cu VCSUpdate
"   <Leader>cU VCSUnlock
"   <Leader>cv VCSVimDiff
"
" Options documentation: {{{2
"
" Several variables are checked by the script to determine behavior as follow:
"
" VCSCommandCommitOnWrite
"   This variable, if set to a non-zero value, causes the pending commit to
"   take place immediately as soon as the log message buffer is written.  If
"   set to zero, only the VCSCommit mapping will cause the pending commit to
"   occur.  If not set, it defaults to 1.
"
" VCSCommandDeleteOnHide
"   This variable, if set to a non-zero value, causes the temporary VCS result
"   buffers to automatically delete themselves when hidden.
"
" VCSCommand{VCSType}DiffOpt
"   This variable, if set, determines the options passed to the diff command
"   of the underlying VCS.  Each VCS plugin defines a default value.
"
" VCSCommandDiffSplit
"   This variable overrides the VCSCommandSplit variable, but only for buffers
"   created with VCSVimDiff.
"
" VCSCommandEdit
"   This variable controls whether to split the current window to display a
"   scratch buffer ('split'), or to display it in the current buffer ('edit').
"   If not set, it defaults to 'split'.
"
" VCSCommandEnableBufferSetup
"   This variable, if set to a non-zero value, activates VCS buffer management
"   mode.  This mode means that the buffer variable 'VCSRevision' is set if
"   the file is VCS-controlled.  This is useful for displaying version
"   information in the status bar.  Additional options may be set by
"   individual VCS plugins.
"
" VCSCommandResultBufferNameExtension
"   This variable, if set to a non-blank value, is appended to the name of the
"   VCS command output buffers.  For example, '.vcs'.  Using this option may
"   help avoid problems caused by autocommands dependent on file extension.
"
" VCSCommandResultBufferNameFunction
"   This variable, if set, specifies a custom function for naming VCS command
"   output buffers.  This function will be passed the following arguments:
"
"   command - name of the VCS command being executed (such as 'Log' or
"   'Diff').
"
"   originalBuffer - buffer number of the source file.
"
"   vcsType - type of VCS controlling this file (such as 'CVS' or 'SVN').
"
"   statusText - extra text associated with the VCS action (such as version
"   numbers).
"
" VCSCommandSplit
"   This variable controls the orientation of the various window splits that
"   may occur (such as with VCSVimDiff, when using a VCS command on a VCS
"   command buffer, or when the 'VCSCommandEdit' variable is set to 'split'.
"   If set to 'horizontal', the resulting windows will be on stacked on top of
"   one another.  If set to 'vertical', the resulting windows will be
"   side-by-side.  If not set, it defaults to 'horizontal' for all but
"   VCSVimDiff windows.
"
" Event documentation {{{2
"   For additional customization, VCSCommand.vim uses User event autocommand
"   hooks.  Each event is in the VCSCommand group, and different patterns
"   match the various hooks.
"
"   For instance, the following could be added to the vimrc to provide a 'q'
"   mapping to quit a VCS scratch buffer:
"
"   augroup VCSCommand
"     au VCSCommand User VCSBufferCreated silent! nmap <unique> <buffer> q :bwipeout<cr> 
"   augroup END
"
"   The following hooks are available:
"
"   VCSBufferCreated           This event is fired just after a VCS command
"                              output buffer is created.  It is executed
"                              within the context of the new buffer.
"
"   VCSBufferSetup             This event is fired just after VCS buffer setup
"                              occurs, if enabled.
"
"   VCSLoadExtensions          This event is fired just before the
"                              VCSPluginFinish event.  It is intended to be
"                              used only by VCS extensions to register
"                              themselves with VCSCommand if they are sourced
"                              first.
"
"   VCSPluginInit              This event is fired when the VCSCommand plugin
"                              first loads.
"
"   VCSPluginFinish            This event is fired just after the VCSCommand
"                              plugin loads.
"
"   VCSVimDiffFinish           This event is fired just after the VCSVimDiff
"                              command executes to allow customization of,
"                              for instance, window placement and focus.
"
" Section: Plugin header {{{1

" loaded_VCSCommand is set to 1 when the initialization begins, and 2 when it
" completes.  This allows various actions to only be taken by functions after
" system initialization.

if exists('loaded_VCSCommand')
   finish
endif
let loaded_VCSCommand = 1

if v:version < 700
  echohl WarningMsg|echomsg 'VCSCommand requires at least VIM 7.0'|echohl None
  finish
endif

" Section: Event group setup {{{1

augroup VCSCommand
augroup END

augroup VCSCommandCommit
augroup END

" Section: Plugin initialization {{{1
silent do VCSCommand User VCSPluginInit

" Section: Script variable initialization {{{1

let s:plugins = {}
let s:pluginFiles = []
let s:extendedMappings = {}
let s:optionOverrides = {}
let s:isEditFileRunning = 0

unlet! s:vimDiffRestoreCmd
unlet! s:vimDiffSourceBuffer
unlet! s:vimDiffScratchList

" Section: Utility functions {{{1

" Function: s:ReportError(mapping) {{{2
" Displays the given error in a consistent faction.  This is intended to be
" invoked from a catch statement.

function! s:ReportError(error)
  echohl WarningMsg|echomsg 'VCSCommand:  ' . a:error|echohl None
endfunction

" Function: s:ExecuteExtensionMapping(mapping) {{{2
" Invokes the appropriate extension mapping depending on the type of the
" current buffer.

function! s:ExecuteExtensionMapping(mapping)
  let buffer = bufnr('%')
  let vcsType = VCSCommandGetVCSType(buffer)
  if !has_key(s:extendedMappings, vcsType)
    throw 'Unknown VCS type:  ' . vcsType
  endif
  if !has_key(s:extendedMappings[vcsType], a:mapping)
    throw 'This extended mapping is not defined for ' . vcsType
  endif
  silent execute 'normal' ':' .  s:extendedMappings[vcsType][a:mapping] . "\<CR>"
endfunction

" Function: s:ExecuteVCSCommand(command, argList) {{{2
" Calls the indicated plugin-specific VCS command on the current buffer.
" Returns: buffer number of resulting output scratch buffer, or -1 if an error
" occurs.

function! s:ExecuteVCSCommand(command, argList, verifyBuffer)
  try
    let buffer = bufnr('%')

    let vcsType = VCSCommandGetVCSType(buffer)
    if !has_key(s:plugins, vcsType)
      throw 'Unknown VCS type:  ' . vcsType
    endif

    let originalBuffer = VCSCommandGetOriginalBuffer(buffer)
    let bufferName = bufname(originalBuffer)
    if !isdirectory(bufferName) && !filereadable(bufferName)
      throw 'No such file ' . bufferName
    endif

    if(a:verifyBuffer)
      let revision = VCSCommandGetRevision()
      if revision == ''
        throw 'Unable to obtain version information.'
      elseif revision == 'Unknown'
        throw 'Item not under source control'
      elseif revision == 'New'
        throw 'Operation not available on newly-added item.'
      endif
    endif

    let functionMap = s:plugins[vcsType]
    if !has_key(functionMap, a:command)
      throw 'Command ''' . a:command . ''' not implemented for ' . vcsType
    endif
    return functionMap[a:command](a:argList)
  catch
    call s:ReportError(v:exception)
    return -1
  endtry
endfunction

" Function: s:CreateCommandBuffer(cmd, cmdName, originalBuffer, statusText) {{{2
" Creates a new scratch buffer and captures the output from execution of the
" given command.  The name of the scratch buffer is returned.

function! s:CreateCommandBuffer(cmd, cmdName, originalBuffer, statusText)
  let output = system(a:cmd)

  " HACK:  if line endings in the repository have been corrupted, the output
  " of the command will be confused.
  let output = substitute(output, "\r", '', 'g')

  " HACK:  CVS diff command does not return proper error codes
  if v:shell_error && (a:cmdName != 'diff' || getbufvar(a:originalBuffer, 'VCSCommandVCSType') != 'CVS')
    if strlen(output) == 0
      throw 'Version control command failed'
    else
      let output = substitute(output, '\n', '  ', 'g')
      throw 'Version control command failed:  ' . output
    endif
  endif
  if strlen(output) == 0
    " Handle case of no output.  In this case, it is important to check the
    " file status, especially since cvs edit/unedit may change the attributes
    " of the file with no visible output.

    checktime
    return 0
  endif

  call s:EditFile(a:cmdName, a:originalBuffer, a:statusText)

  silent 0put=output

  " The last command left a blank line at the end of the buffer.  If the
  " last line is folded (a side effect of the 'put') then the attempt to
  " remove the blank line will kill the last fold.
  "
  " This could be fixed by explicitly detecting whether the last line is
  " within a fold, but I prefer to simply unfold the result buffer altogether.

  if has('folding')
    normal zR
  endif

  $d
  1

  " Define the environment and execute user-defined hooks.

  silent do VCSCommand User VCSBufferCreated
  return bufnr('%')
endfunction

" Function: s:GenerateResultBufferName(command, originalBuffer, vcsType, statusText) {{{2
" Default method of generating the name for VCS result buffers.  This can be
" overridden with the VCSResultBufferNameFunction variable.

function! s:GenerateResultBufferName(command, originalBuffer, vcsType, statusText)
  let fileName = bufname(a:originalBuffer)
  let bufferName = a:vcsType . ' ' . a:command
  if strlen(a:statusText) > 0
    let bufferName .= ' ' . a:statusText
  endif
  let bufferName .= ' ' . fileName
  let counter = 0
  let versionedBufferName = bufferName
  while buflisted(versionedBufferName)
    let counter += 1
    let versionedBufferName = bufferName . ' (' . counter . ')'
  endwhile
  return versionedBufferName
endfunction

" Function: s:GenerateResultBufferNameWithExtension(command, originalBuffer, vcsType, statusText) {{{2
" Method of generating the name for VCS result buffers that uses the original
" file name with the VCS type and command appended as extensions.

function! s:GenerateResultBufferNameWithExtension(command, originalBuffer, vcsType, statusText)
  let fileName = bufname(a:originalBuffer)
  let bufferName = a:vcsType . ' ' . a:command
  if strlen(a:statusText) > 0
    let bufferName .= ' ' . a:statusText
  endif
  let bufferName .= ' ' . fileName . VCSCommandGetOption('VCSCommandResultBufferNameExtension', '.vcs')
  let counter = 0
  let versionedBufferName = bufferName
  while buflisted(versionedBufferName)
    let counter += 1
    let versionedBufferName = '(' . counter . ') ' . bufferName
  endwhile
  return versionedBufferName
endfunction

" Function: s:EditFile(command, originalBuffer, statusText) {{{2
" Creates a new buffer of the given name and associates it with the given
" original buffer.

function! s:EditFile(command, originalBuffer, statusText)
  let vcsType = getbufvar(a:originalBuffer, 'VCSCommandVCSType')

  let nameExtension = VCSCommandGetOption('VCSCommandResultBufferNameExtension', '')
  if nameExtension == ''
    let nameFunction = VCSCommandGetOption('VCSCommandResultBufferNameFunction', 's:GenerateResultBufferName')
  else
    let nameFunction = VCSCommandGetOption('VCSCommandResultBufferNameFunction', 's:GenerateResultBufferNameWithExtension')
  endif

  let resultBufferName = call(nameFunction, [a:command, a:originalBuffer, vcsType, a:statusText])

  " Protect against useless buffer set-up
  let s:isEditFileRunning += 1
  try
    let editCommand = VCSCommandGetOption('VCSCommandEdit', 'split')
    if editCommand == 'split'
      if VCSCommandGetOption('VCSCommandSplit', 'horizontal') == 'horizontal'
        rightbelow split
      else
        vert rightbelow split
      endif
    endif
    edit `=resultBufferName`
    let b:VCSCommandCommand = a:command
    let b:VCSCommandOriginalBuffer = a:originalBuffer
    let b:VCSCommandSourceFile = bufname(a:originalBuffer)
    let b:VCSCommandVCSType = vcsType

    set buftype=nofile
    set noswapfile
    let &filetype = vcsType . a:command

    if a:statusText != ''
      let b:VCSCommandStatusText = a:statusText
    endif

    if VCSCommandGetOption('VCSCommandDeleteOnHide', 0)
      set bufhidden=delete
    endif
  finally
    let s:isEditFileRunning -= 1
  endtry

endfunction

" Function: s:SetupBuffer() {{{2
" Attempts to set the b:VCSCommandBufferInfo variable

function! s:SetupBuffer()
  if (exists('b:VCSCommandBufferSetup') && b:VCSCommandBufferSetup)
    " This buffer is already set up.
    return
  endif

  if strlen(&buftype) > 0 || !filereadable(@%)
    " No special status for special buffers.
    return
  endif

  if !VCSCommandGetOption('VCSCommandEnableBufferSetup', 0) || s:isEditFileRunning > 0
    unlet! b:VCSCommandBufferSetup
    return
  endif

  try
    let vcsType = VCSCommandGetVCSType(bufnr('%'))
    let b:VCSCommandBufferInfo =  s:plugins[vcsType].GetBufferInfo()
    silent do VCSCommand User VCSBufferSetup
  catch /No suitable plugin/
    " This is not a VCS-controlled file.
    let b:VCSCommandBufferInfo = []
  endtry

  let b:VCSCommandBufferSetup = 1
endfunction

" Function: s:MarkOrigBufferForSetup(buffer) {{{2
" Resets the buffer setup state of the original buffer for a given VCS scratch
" buffer.
" Returns:  The VCS buffer number in a passthrough mode.

function! s:MarkOrigBufferForSetup(buffer)
  checktime
  if a:buffer > 0 
    let origBuffer = VCSCommandGetOriginalBuffer(a:buffer)
    " This should never not work, but I'm paranoid
    if origBuffer != a:buffer
      call setbufvar(origBuffer, 'VCSCommandBufferSetup', 0)
    endif
  endif
  return a:buffer
endfunction

" Function: s:OverrideOption(option, [value]) {{{2
" Provides a temporary override for the given VCS option.  If no value is
" passed, the override is disabled.

function! s:OverrideOption(option, ...)
  if a:0 == 0
    call remove(s:optionOverrides[a:option], -1)
  else
    if !has_key(s:optionOverrides, a:option)
      let s:optionOverrides[a:option] = []
    endif
    call add(s:optionOverrides[a:option], a:1)
  endif
endfunction

" Function: s:WipeoutCommandBuffers() {{{2
" Clears all current VCS output buffers of the specified type for a given source.

function! s:WipeoutCommandBuffers(originalBuffer, VCSCommand)
  let buffer = 1
  while buffer <= bufnr('$')
    if getbufvar(buffer, 'VCSCommandOriginalBuffer') == a:originalBuffer
      if getbufvar(buffer, 'VCSCommandCommand') == a:VCSCommand
        execute 'bw' buffer
      endif
    endif
    let buffer = buffer + 1
  endwhile
endfunction

" Function: s:VimDiffRestore(vimDiffBuff) {{{2
" Checks whether the given buffer is one whose deletion should trigger
" restoration of an original buffer after it was diffed.  If so, it executes
" the appropriate setting command stored with that original buffer.

function! s:VimDiffRestore(vimDiffBuff)
  let s:isEditFileRunning += 1
  try
    if exists('s:vimDiffSourceBuffer')
      if a:vimDiffBuff == s:vimDiffSourceBuffer
        " Original file is being removed.
        unlet! s:vimDiffSourceBuffer
        unlet! s:vimDiffRestoreCmd
        unlet! s:vimDiffScratchList
      else
        let index = index(s:vimDiffScratchList, a:vimDiffBuff)
        if index >= 0
          call remove(s:vimDiffScratchList, index)
          if len(s:vimDiffScratchList) == 0
            if exists('s:vimDiffRestoreCmd')
              " All scratch buffers are gone, reset the original.
              " Only restore if the source buffer is still in Diff mode

              let sourceWinNR = bufwinnr(s:vimDiffSourceBuffer)
              if sourceWinNR != -1
                " The buffer is visible in at least one window
                let currentWinNR = winnr()
                while winbufnr(sourceWinNR) != -1
                  if winbufnr(sourceWinNR) == s:vimDiffSourceBuffer
                    execute sourceWinNR . 'wincmd w'
                    if getwinvar(0, '&diff')
                      execute s:vimDiffRestoreCmd
                    endif
                  endif
                  let sourceWinNR = sourceWinNR + 1
                endwhile
                execute currentWinNR . 'wincmd w'
              else
                " The buffer is hidden.  It must be visible in order to set the
                " diff option.
                let currentBufNR = bufnr('')
                execute 'hide buffer' s:vimDiffSourceBuffer
                if getwinvar(0, '&diff')
                  execute s:vimDiffRestoreCmd
                endif
                execute 'hide buffer' currentBufNR
              endif

              unlet s:vimDiffRestoreCmd
            endif 
            " All buffers are gone.
            unlet s:vimDiffSourceBuffer
            unlet s:vimDiffScratchList
          endif
        endif
      endif
    endif
  finally
    let s:isEditFileRunning -= 1
  endtry
endfunction

" Section: Generic VCS command functions {{{1

" Function: s:VCSCommit() {{{2
function! s:VCSCommit(bang, message)
  try
    let vcsType = VCSCommandGetVCSType(bufnr('%'))
    if !has_key(s:plugins, vcsType)
      throw 'Unknown VCS type:  ' . vcsType
    endif

    let originalBuffer = VCSCommandGetOriginalBuffer(bufnr('%'))

    " Handle the commit message being specified.  If a message is supplied, it
    " is used; if bang is supplied, an empty message is used; otherwise, the
    " user is provided a buffer from which to edit the commit message.

    if strlen(a:message) > 0 || a:bang == '!'
      return s:VCSFinishCommit([a:message], originalBuffer)
    endif

    call s:EditFile('commitlog', originalBuffer, '')
    set ft=vcscommit

    " Create a commit mapping.

    nnoremap <silent> <buffer> <Plug>VCSCommit :call <SID>VCSFinishCommitWithBuffer()<CR>

    silent 0put ='VCS: ----------------------------------------------------------------------'
    silent put ='VCS: Please enter log message.  Lines beginning with ''VCS:'' are removed automatically.'
    silent put ='VCS: To finish the commit, Type <leader>cc (or your own <Plug>VCSCommit mapping)'

    if VCSCommandGetOption('VCSCommandCommitOnWrite', 1) == 1
      set buftype=acwrite
      au VCSCommandCommit BufWriteCmd <buffer> call s:VCSFinishCommitWithBuffer()
      silent put ='VCS: or write this buffer'
    endif

    silent put ='VCS: ----------------------------------------------------------------------'
    $
    set nomodified
  catch
    call s:ReportError(v:exception)
    return -1
  endtry
endfunction

" Function: s:VCSFinishCommitWithBuffer() {{{2
" Wrapper for s:VCSFinishCommit which is called only from a commit log buffer
" which removes all lines starting with 'VCS:'.

function! s:VCSFinishCommitWithBuffer()
  set nomodified
  let currentBuffer = bufnr('%') 
  let logMessageList = getbufline('%', 1, '$')
  call filter(logMessageList, 'v:val !~ ''^\s*VCS:''')
  let resultBuffer = s:VCSFinishCommit(logMessageList, b:VCSCommandOriginalBuffer)
  if resultBuffer >= 0
    execute 'bw' currentBuffer
  endif
  return resultBuffer
endfunction

" Function: s:VCSFinishCommit(logMessageList, originalBuffer) {{{2
function! s:VCSFinishCommit(logMessageList, originalBuffer)
  let shellSlashBak = &shellslash
  try
    set shellslash
    let messageFileName = tempname()
    call writefile(a:logMessageList, messageFileName)
    try
      let resultBuffer = s:ExecuteVCSCommand('Commit', [messageFileName], 0)
      if resultBuffer < 0
        return resultBuffer
      endif
      return s:MarkOrigBufferForSetup(resultBuffer)
    finally
      call delete(messageFileName)
    endtry
  finally
    let &shellslash = shellSlashBak
  endtry
endfunction

" Function: s:VCSGotoOriginal(bang) {{{2
function! s:VCSGotoOriginal(bang)
  let originalBuffer = VCSCommandGetOriginalBuffer(bufnr('%'))
  if originalBuffer > 0
    let origWinNR = bufwinnr(originalBuffer)
    if origWinNR == -1
      execute 'buffer' originalBuffer
    else
      execute origWinNR . 'wincmd w'
    endif
    if a:bang == '!'
      let buffnr = 1
      let buffmaxnr = bufnr('$')
      while buffnr <= buffmaxnr
        if getbufvar(buffnr, 'VCSCommandOriginalBuffer') == originalBuffer
          execute 'bw' buffnr
        endif
        let buffnr = buffnr + 1
      endwhile
    endif
  endif
endfunction

" Function: s:VCSVimDiff(...) {{{2
function! s:VCSVimDiff(...)
  try
    let vcsType = VCSCommandGetVCSType(bufnr('%'))
    if !has_key(s:plugins, vcsType)
      throw 'Unknown VCS type:  ' . vcsType
    endif
    let originalBuffer = VCSCommandGetOriginalBuffer(bufnr('%'))
    let s:isEditFileRunning = s:isEditFileRunning + 1
    try
      " If there's already a VimDiff'ed window, restore it.
      " There may only be one VCSVimDiff original window at a time.

      if exists('s:vimDiffSourceBuffer') && s:vimDiffSourceBuffer != originalBuffer
        " Clear the existing vimdiff setup by removing the result buffers.
        call s:WipeoutCommandBuffers(s:vimDiffSourceBuffer, 'vimdiff')
      endif

      " Split and diff
      if(a:0 == 2)
        " Reset the vimdiff system, as 2 explicit versions were provided.
        if exists('s:vimDiffSourceBuffer')
          call s:WipeoutCommandBuffers(s:vimDiffSourceBuffer, 'vimdiff')
        endif
        let resultBuffer = s:plugins[vcsType].Review([a:1])
        if resultBuffer < 0
          echomsg 'Can''t open revision ' . a:1
          return resultBuffer
        endif
        let b:VCSCommandCommand = 'vimdiff'
        diffthis
        let s:vimDiffScratchList = [resultBuffer]
        " If no split method is defined, cheat, and set it to vertical.
        try
          call s:OverrideOption('VCSCommandSplit', VCSCommandGetOption('VCSCommandDiffSplit', VCSCommandGetOption('VCSCommandSplit', 'vertical')))
          let resultBuffer = s:plugins[vcsType].Review([a:2])
        finally
          call s:OverrideOption('VCSCommandSplit')
        endtry
        if resultBuffer < 0
          echomsg 'Can''t open revision ' . a:1
          return resultBuffer
        endif
        let b:VCSCommandCommand = 'vimdiff'
        diffthis
        let s:vimDiffScratchList += [resultBuffer]
      else
        " Add new buffer
        call s:OverrideOption('VCSCommandEdit', 'split')
        try
          " Force splitting behavior, otherwise why use vimdiff?
          call s:OverrideOption('VCSCommandSplit', VCSCommandGetOption('VCSCommandDiffSplit', VCSCommandGetOption('VCSCommandSplit', 'vertical')))
          try
            if(a:0 == 0)
              let resultBuffer = s:plugins[vcsType].Review([])
            else
              let resultBuffer = s:plugins[vcsType].Review([a:1])
            endif
          finally
            call s:OverrideOption('VCSCommandSplit')
          endtry
        finally
          call s:OverrideOption('VCSCommandEdit')
        endtry
        if resultBuffer < 0
          echomsg 'Can''t open current revision'
          return resultBuffer
        endif
        let b:VCSCommandCommand = 'vimdiff'
        diffthis

        if !exists('s:vimDiffSourceBuffer')
          " New instance of vimdiff.
          let s:vimDiffScratchList = [resultBuffer]

          " This could have been invoked on a VCS result buffer, not the
          " original buffer.
          wincmd W
          execute 'buffer' originalBuffer
          " Store info for later original buffer restore
          let s:vimDiffRestoreCmd = 
                \    'call setbufvar('.originalBuffer.', ''&diff'', '.getbufvar(originalBuffer, '&diff').')'
                \ . '|call setbufvar('.originalBuffer.', ''&foldcolumn'', '.getbufvar(originalBuffer, '&foldcolumn').')'
                \ . '|call setbufvar('.originalBuffer.', ''&foldenable'', '.getbufvar(originalBuffer, '&foldenable').')'
                \ . '|call setbufvar('.originalBuffer.', ''&foldmethod'', '''.getbufvar(originalBuffer, '&foldmethod').''')'
                \ . '|call setbufvar('.originalBuffer.', ''&scrollbind'', '.getbufvar(originalBuffer, '&scrollbind').')'
                \ . '|call setbufvar('.originalBuffer.', ''&wrap'', '.getbufvar(originalBuffer, '&wrap').')'
                \ . '|if &foldmethod==''manual''|execute ''normal zE''|endif'
          diffthis
          wincmd w
        else
          " Adding a window to an existing vimdiff
          let s:vimDiffScratchList += [resultBuffer]
        endif
      endif

      let s:vimDiffSourceBuffer = originalBuffer

      " Avoid executing the modeline in the current buffer after the autocommand.

      let currentBuffer = bufnr('%')
      let saveModeline = getbufvar(currentBuffer, '&modeline')
      try
        call setbufvar(currentBuffer, '&modeline', 0)
        silent do VCSCommand User VCSVimDiffFinish
      finally
        call setbufvar(currentBuffer, '&modeline', saveModeline)
      endtry
      return resultBuffer
    finally
      let s:isEditFileRunning = s:isEditFileRunning - 1
    endtry
  catch
    call s:ReportError(v:exception)
    return -1
  endtry
endfunction

" Section: Public functions {{{1

" Function: VCSCommandGetVCSType() {{{2
" Sets the b:VCSCommandVCSType variable in the given buffer to the
" appropriate source control system name.

function! VCSCommandGetVCSType(buffer)
  let vcsType = getbufvar(a:buffer, 'VCSCommandVCSType')
  if strlen(vcsType) > 0
    return vcsType
  endif
  for vcsType in keys(s:plugins)
    if s:plugins[vcsType].Identify(a:buffer)
      call setbufvar(a:buffer, 'VCSCommandVCSType', vcsType)
      return vcsType
    endif
  endfor
  throw 'No suitable plugin'
endfunction

" Function: VCSCommandChangeToCurrentFileDir() {{{2
" Go to the directory in which the given file is located.

function! VCSCommandChangeToCurrentFileDir(fileName)
  let oldCwd = getcwd()
  let newCwd = fnamemodify(resolve(a:fileName), ':p:h')
  if strlen(newCwd) > 0
    execute 'cd' escape(newCwd, ' ')
  endif
  return oldCwd
endfunction

" Function: VCSCommandGetOriginalBuffer(vcsBuffer) {{{2
" Attempts to locate the original file to which VCS operations were applied
" for a given buffer.

function! VCSCommandGetOriginalBuffer(vcsBuffer)
  let origBuffer = getbufvar(a:vcsBuffer, 'VCSCommandOriginalBuffer')
  if origBuffer
    if bufexists(origBuffer)
      return origBuffer
    else
      " Original buffer no longer exists.
      throw 'Original buffer for this VCS buffer no longer exists.'
    endif
  else
    " No original buffer
    return a:vcsBuffer
  endif
endfunction

" Function: VCSCommandRegisterModule(name, file, commandMap) {{{2
" Allows VCS modules to register themselves.

function! VCSCommandRegisterModule(name, file, commandMap, mappingMap)
  let s:plugins[a:name] = a:commandMap
  call add(s:pluginFiles, a:file)
  let s:extendedMappings[a:name] = a:mappingMap
  if(!empty(a:mappingMap))
    for mapname in keys(a:mappingMap)
      execute 'noremap <silent> <Leader>' . mapname ':call <SID>ExecuteExtensionMapping(''' . mapname . ''')<CR>'
    endfor
  endif
endfunction

" Function: VCSCommandDoCommand(cmd, cmdName, statusText) {{{2
" General skeleton for VCS function execution.
" Returns: name of the new command buffer containing the command results

function! VCSCommandDoCommand(cmd, cmdName, statusText)
  let originalBuffer = VCSCommandGetOriginalBuffer(bufnr('%'))
  if originalBuffer == -1 
    throw 'Original buffer no longer exists, aborting.'
  endif

  let fileName = resolve(bufname(originalBuffer))

  " Work with netrw or other systems where a directory listing is displayed in
  " a buffer.

  if isdirectory(fileName)
    let realFileName = '.'
  else
    let realFileName = fnamemodify(fileName, ':t')
  endif

  let oldCwd = VCSCommandChangeToCurrentFileDir(fileName)
  try
    let fullCmd = a:cmd . ' "' . realFileName . '"'
    let resultBuffer = s:CreateCommandBuffer(fullCmd, a:cmdName, originalBuffer, a:statusText)
    return resultBuffer
  finally
    execute 'cd' escape(oldCwd, ' ')
  endtry
endfunction

" Function: VCSCommandGetOption(name, default) {{{2
" Grab a user-specified option to override the default provided.  Options are
" searched in the window, buffer, then global spaces.

function! VCSCommandGetOption(name, default)
  if has_key(s:optionOverrides, a:name) && len(s:optionOverrides[a:name]) > 0
    return s:optionOverrides[a:name][-1]
  elseif exists('w:' . a:name)
    return w:{a:name}
  elseif exists('b:' . a:name)
    return b:{a:name}
  elseif exists('g:' . a:name)
    return g:{a:name}
  else
    return a:default
  endif
endfunction

" Function: VCSCommandGetRevision() {{{2
" Global function for retrieving the current buffer's revision number.
" Returns: Revision number or an empty string if an error occurs.

function! VCSCommandGetRevision()
  if !exists('b:VCSCommandBufferInfo')
    let b:VCSCommandBufferInfo =  s:plugins[VCSCommandGetVCSType(bufnr('%'))].GetBufferInfo()
  endif

  if len(b:VCSCommandBufferInfo) > 0
    return b:VCSCommandBufferInfo[0]
  else
    return ''
  endif
endfunction

" Function: VCSCommandDisableBufferSetup() {{{2
" Global function for deactivating the buffer autovariables.

function! VCSCommandDisableBufferSetup()
  let g:VCSCommandEnableBufferSetup = 0
  silent! augroup! VCSCommandPlugin
endfunction

" Function: VCSCommandEnableBufferSetup() {{{2
" Global function for activating the buffer autovariables.

function! VCSCommandEnableBufferSetup()
  let g:VCSCommandEnableBufferSetup = 1
  augroup VCSCommandPlugin
    au!
    au BufEnter * call s:SetupBuffer()
  augroup END

  " Only auto-load if the plugin is fully loaded.  This gives other plugins a
  " chance to run.
  if g:loaded_VCSCommand == 2
    call s:SetupBuffer()
  endif
endfunction

" Function: VCSCommandGetStatusLine() {{{2
" Default (sample) status line entry for VCS-controlled files.  This is only
" useful if VCS-managed buffer mode is on (see the VCSCommandEnableBufferSetup
" variable for how to do this).

function! VCSCommandGetStatusLine()
  if exists('b:VCSCommandCommand')
    " This is a result buffer.  Return nothing because the buffer name
    " contains information already.
    return ''
  endif

  if exists('b:VCSCommandVCSType')
        \ && exists('g:VCSCommandEnableBufferSetup')
        \ && g:VCSCommandEnableBufferSetup
        \ && exists('b:VCSCommandBufferInfo')
    return '[' . join(extend([b:VCSCommandVCSType], b:VCSCommandBufferInfo), ' ') . ']'
  else
    return ''
  endif
endfunction

" Section: Command definitions {{{1
" Section: Primary commands {{{2
com! -nargs=* VCSAdd call s:MarkOrigBufferForSetup(s:ExecuteVCSCommand('Add', [<f-args>], 0))
com! -nargs=* VCSAnnotate call s:ExecuteVCSCommand('Annotate', [<f-args>], 1)
com! -nargs=? -bang VCSCommit call s:VCSCommit(<q-bang>, <q-args>)
com! -nargs=* VCSDelete call s:ExecuteVCSCommand('Delete', [<f-args>], 1)
com! -nargs=* VCSDiff call s:ExecuteVCSCommand('Diff', [<f-args>], 1)
com! -nargs=0 -bang VCSGotoOriginal call s:VCSGotoOriginal(<q-bang>)
com! -nargs=* VCSInfo call s:ExecuteVCSCommand('Info', [<f-args>], 1)
com! -nargs=* VCSLock call s:MarkOrigBufferForSetup(s:ExecuteVCSCommand('Lock', [<f-args>], 1))
com! -nargs=* VCSLog call s:ExecuteVCSCommand('Log', [<f-args>], 1)
com! -nargs=0 VCSRevert call s:MarkOrigBufferForSetup(s:ExecuteVCSCommand('Revert', [], 1))
com! -nargs=? VCSReview call s:ExecuteVCSCommand('Review', [<f-args>], 1)
com! -nargs=* VCSStatus call s:ExecuteVCSCommand('Status', [<f-args>], 1)
com! -nargs=* VCSUnlock call s:MarkOrigBufferForSetup(s:ExecuteVCSCommand('Unlock', [<f-args>], 1))
com! -nargs=0 VCSUpdate call s:MarkOrigBufferForSetup(s:ExecuteVCSCommand('Update', [], 1))
com! -nargs=* VCSVimDiff call s:VCSVimDiff(<f-args>)

" Section: VCS buffer management commands {{{2
com! VCSCommandDisableBufferSetup call VCSCommandDisableBufferSetup()
com! VCSCommandEnableBufferSetup call VCSCommandEnableBufferSetup()

" Allow reloading VCSCommand.vim
com! VCSReload let savedPluginFiles = s:pluginFiles|aunmenu Plugin.VCS|unlet! g:loaded_VCSCommand|runtime plugin/vcscommand.vim|for file in savedPluginFiles|execute 'source' file|endfor

" Section: Plugin command mappings {{{1
nnoremap <silent> <Plug>VCSAdd :VCSAdd<CR>
nnoremap <silent> <Plug>VCSAnnotate :VCSAnnotate<CR>
nnoremap <silent> <Plug>VCSCommit :VCSCommit<CR>
nnoremap <silent> <Plug>VCSDelete :VCSDelete<CR>
nnoremap <silent> <Plug>VCSDiff :VCSDiff<CR>
nnoremap <silent> <Plug>VCSGotoOriginal :VCSGotoOriginal<CR>
nnoremap <silent> <Plug>VCSClearAndGotoOriginal :VCSGotoOriginal!<CR>
nnoremap <silent> <Plug>VCSInfo :VCSInfo<CR>
nnoremap <silent> <Plug>VCSLock :VCSLock<CR>
nnoremap <silent> <Plug>VCSLog :VCSLog<CR>
nnoremap <silent> <Plug>VCSRevert :VCSRevert<CR>
nnoremap <silent> <Plug>VCSReview :VCSReview<CR>
nnoremap <silent> <Plug>VCSStatus :VCSStatus<CR>
nnoremap <silent> <Plug>VCSUnlock :VCSUnlock<CR>
nnoremap <silent> <Plug>VCSUpdate :VCSUpdate<CR>
nnoremap <silent> <Plug>VCSVimDiff :VCSVimDiff<CR>

" Section: Default mappings {{{1
if !hasmapto('<Plug>VCSAdd')
  nmap <unique> <Leader>ca <Plug>VCSAdd
endif
if !hasmapto('<Plug>VCSAnnotate')
  nmap <unique> <Leader>cn <Plug>VCSAnnotate
endif
if !hasmapto('<Plug>VCSClearAndGotoOriginal')
  nmap <unique> <Leader>cG <Plug>VCSClearAndGotoOriginal
endif
if !hasmapto('<Plug>VCSCommit')
  nmap <unique> <Leader>cc <Plug>VCSCommit
endif
if !hasmapto('<Plug>VCSDelete')
  nmap <unique> <Leader>cD <Plug>VCSDelete
endif
if !hasmapto('<Plug>VCSDiff')
  nmap <unique> <Leader>cd <Plug>VCSDiff
endif
if !hasmapto('<Plug>VCSGotoOriginal')
  nmap <unique> <Leader>cg <Plug>VCSGotoOriginal
endif
if !hasmapto('<Plug>VCSInfo')
  nmap <unique> <Leader>ci <Plug>VCSInfo
endif
if !hasmapto('<Plug>VCSLock')
  nmap <unique> <Leader>cL <Plug>VCSLock
endif
if !hasmapto('<Plug>VCSLog')
  nmap <unique> <Leader>cl <Plug>VCSLog
endif
if !hasmapto('<Plug>VCSRevert')
  nmap <unique> <Leader>cq <Plug>VCSRevert
endif
if !hasmapto('<Plug>VCSReview')
  nmap <unique> <Leader>cr <Plug>VCSReview
endif
if !hasmapto('<Plug>VCSStatus')
  nmap <unique> <Leader>cs <Plug>VCSStatus
endif
if !hasmapto('<Plug>VCSUnlock')
  nmap <unique> <Leader>cU <Plug>VCSUnlock
endif
if !hasmapto('<Plug>VCSUpdate')
  nmap <unique> <Leader>cu <Plug>VCSUpdate
endif
if !hasmapto('<Plug>VCSVimDiff')
  nmap <unique> <Leader>cv <Plug>VCSVimDiff
endif

" Section: Menu items {{{1
amenu <silent> &Plugin.VCS.&Add        <Plug>VCSAdd
amenu <silent> &Plugin.VCS.A&nnotate   <Plug>VCSAnnotate
amenu <silent> &Plugin.VCS.&Commit     <Plug>VCSCommit
amenu <silent> &Plugin.VCS.Delete      <Plug>VCSDelete
amenu <silent> &Plugin.VCS.&Diff       <Plug>VCSDiff
amenu <silent> &Plugin.VCS.&Info       <Plug>VCSInfo
amenu <silent> &Plugin.VCS.&Log        <Plug>VCSLog
amenu <silent> &Plugin.VCS.Revert      <Plug>VCSRevert
amenu <silent> &Plugin.VCS.&Review     <Plug>VCSReview
amenu <silent> &Plugin.VCS.&Status     <Plug>VCSStatus
amenu <silent> &Plugin.VCS.&Update     <Plug>VCSUpdate
amenu <silent> &Plugin.VCS.&VimDiff    <Plug>VCSVimDiff

" Section: Autocommands to restore vimdiff state {{{1
augroup VimDiffRestore
  au!
  au BufUnload * call s:VimDiffRestore(str2nr(expand('<abuf>')))
augroup END

" Section: Optional activation of buffer management {{{1

if VCSCommandGetOption('VCSCommandEnableBufferSetup', 0)
  call VCSCommandEnableBufferSetup()
endif

" Section: Plugin completion {{{1

let loaded_VCSCommand = 2

" Load delayed extension plugin registration.
silent do VCSCommand User VCSLoadExtensions
au! VCSCommand User VCSLoadExtensions

silent do VCSCommand User VCSPluginFinish
