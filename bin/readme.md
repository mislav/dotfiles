## Mislav's command-line utilities for absolute winning

The following is a non-comprehensive list.

### Code helpers

* [`js-no-comments <js-file>`](./js-no-comments)  
  Strips comments from JavaScript file.
* [`json [<files>...]`](./json)  
  Pretty-print JSON input.
* [`loc [<GITHUB-URL>] [bin lib libexec src]`](./loc)  
  Count lines of code (excluding comments and blank lines) in given files and
  directories. With a GitHub project URL, it will download that project's
  source code and perform the search there.
* [`websize <URL>`](./websize)  
  Downloads a web page including assets and displays the total size downloaded.
  Note: doesn't take possible compression into account.
* [`search-and-replace [-w] <term> <replacement>`](./search-and-replace)  
  Search for <term> with `ag` and use `sed` to substitute it with <replacement>.
  Outputs file names where substitution has been made.

### Git utilities

* [`changelog [<range>] [-- <directory> ...]`](./changelog)  
  Displays git log in a format suitable for change log. If no range given,
  displays log from the last git tag reachable from this branch. Use
  `<directory>` to filter down entries to just files that contain runtime code.
* [`git autofixup`](./git-autofixup)  
  Commits the staged change as a fixup for the last commit that touched the
  changed line. Useful for preparing for a `git rebase --autosquash`.
* [`git big-file [HEAD [<treshold>]]`](./git-big-file)  
  Find large git objects. `<treshold>` is in MB and the default is 0.1.
* [`git branches-that-touch <path>`](./git-branches-that-touch)  
  Searches branches that touch files under `<path>`, that are remote and unmerged.
* [`git longest-message [<branch>]`](./git-longest-message)  
  Displays 5 of your commits with most words per commit message body.
* [`git overwritten [--[no-]color] [<head=HEAD>] [<base=origin>]`](./git-overwritten)  
  Aggregates git blame information about original owners of lines changed or
  removed in the `<base>...<head>` diff.
* [`git promote [<remote>[/<branch>]]`](./git-promote)  
  Publishes the current branch on a remote and sets up upstream tracking.
* [`git recently-checkout-branches`](./git-recently-checkout-branches)  
  Shows timestamp and name of recently checked-out branches in reverse
  chronological order. This is powered by git-reflog, but excludes branches
  that have since been deleted.
* [`git related <file>`](./git-related)  
  Show other files that often get changed in commits that touch `<file>`.
* [`git resolve`](./git-resolve)  
  Mark all conflicted files as resolved.
* [`git sync`](./git-sync)  
  Fetches new objects from origin remote named either "upstream" or "origin",
  then fast-forwards each local branch that is out of date.
* [`git thanks <range>`](./git-thanks)  
  Show authorship info sorted by the number of commits during `<range>`.
* [`git unpushed-branches`](./git-unpushed-branches)  
  Show unmerged branches that don't have a corresponding branch on the origin remote.
* [`git unreleased`](./git-unreleased)  
  Shows git commits since the last tagged version.
* [`git where <ref>`](./git-where)  
  Shows where a particular commit falls between releases.
* [`git where-pr <ref>`](./git-where-pr)  
  Opens the Pull Request on GitHub where the commit originated.
* [`pr <pr-number> <branch-name> [<remote-name>]`](./pr)  
  Checks out a Pull Request from GitHub as a local branch.
* [`rebase-authors`](./rebase-authors)  
  A filter that annotates `git rebase -i` input with authorship information to
  help you avoid squashing commits together that may have been authored by
  different people.

### Terminal helpers

* [`ansi2html [-w] [--css]`](./ansi2html)  
  Convert terminal color ANSI escape sequences to HTML.
* [`cat-safe <file1> [<file2>...]`](./cat-safe)  
  Like `cat`, but ensures that every file ends with a newline.
* [`colordump [-b]`](./colordump)  
  Dump a table of ASCII colors to a 256-color compatible terminal.
  With `-b`, switch to outputting background color samples.
* [`crlf -i src/*`](./crlf)  
  Convert Windows to Unix line breaks. Use `-i` to change files in-place.
* [`PATH="$(consolidate-path "$PATH")"`](./consolidate-path)  
  Remove duplicate entries from PATH.
* [`lineprof`](./lineprof)  
  Annotates each line of input with the number of milliseconds elapsed since
  the last line. Useful for figuring out slow points of output-producing programs.
* [`stdev`](./stdev)  
  Calculate mean and standard deviation from a stream of numbers passed as lines of input.

### System utilities

* [`battery`](./battery)  
  Show MacBook battery level formatted for tmux status bar.
* [`wifi-pass`](./wifi-pass)  
  Shows SSID and password for the currently connected network. Requires sudo.

### Writing checks

* [`eprime`](./eprime)  
  Highlights usage of the verb "to be" when you're trying to write E-Prime.
* [`passive`](./passive)  
  Highlights possible usage of passive language.
* [`weasel`](./weasel)  
  Highlights weasel words (empty words that sound like they have meaning).

### Tmux utilities

* [`tmux-ps <pattern>`](./tmux-ps)  
  Switch to tmux window which hosts the tty that is controlling the process
  matching <pattern>.
* [`tmux-session`](./tmux-session)  
  Save and restore the state of tmux sessions and windows.
* [`tmux-switch-session [<name>]`](./tmux-switch-session)  
  Switches to the tmux session that starts with the name given, or to the
  previously attached session when name is blank.
* [`tmux-vim-select-pane`](./tmux-vim-select-pane)  
  Like `tmux select-pane`, but sends a `<C-h/j/k/l>` keystroke if Vim is
  running in the current pane, or only one pane exists.
