# dotfiles

Mislav's configuration files for bash, zsh, git, ruby, and more.

## Installation

Clone somewhere, then run the `install` script:

~~~ sh
$ git clone git://github.com/mislav/dotfiles.git ~/dotfiles
$ ~/dotfiles/install
~~~

It won't touch your existing dotfiles, but will symlink the ones that don't
exist. If you want to replace your existing dotfiles, simply move them to a
backup location and run `install` again.

## tmux

C-a
% vertical split
" horizontal split
! break pane into new window
c new window

o select next pane
{ swap pane with previous
} swap pane with next
s interactive session & window browser
w interactive window browser
n next window
p previous window
) next session
( previous session
; select previously active pane
l select previously active window (FIXME)

$ rename session
, rename window

: command prompt
d detach
f search text in open windows

[ copy mode
] paste buffer
# list buffers
- delete buffer
