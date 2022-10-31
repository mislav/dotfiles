# dotfiles

Mislav's configuration files for bash, zsh, git, and more.

## Installation

Clone somewhere, then run the bootstrap script:

~~~ sh
$ git clone https://github.com/mislav/dotfiles.git ~/dotfiles
$ ~/dotfiles/script/bootstrap
~~~

The install script won't overwrite your existing dotfiles, but will symlink
the ones that don't exist. If you want to replace your existing dotfiles, simply
move them to a backup location and run install again.

## Misc. commands in `bin`

Check [the `bin` directory](./bin) for an assortment of useful utilities.

## tmux

- `C-h/j/k/l` - switch to pane in the given direction
- `C-\\` - toggle between last active panes

Under tmux prefix `C-a`:

- `C-l` - clear terminal
- `S` - switch to a session that starts with given name, or switch to the last
  session if no name given
- `m` - open man page in a vertical split
- `g` - tail `log/development.log` in a new window
- `R` - source `~/.tmux.conf` after changes

Regular tmux keybindings:

    % vertical split
    " horizontal split
    ! break pane into new window
    c new window

    o select next pane
    { swap pane with previous
    } swap pane with next
    n next window
    p previous window
    ) next session
    ( previous session
    ; select previously active pane
    l select previously active window

    s interactive session & window browser
    w interactive window browser

    $ rename session
    , rename window

    : command prompt
    d detach
    f search text in open windows

    [ copy mode
    ] paste buffer
    # list buffers
    - delete buffer


[vimfiles]: https://github.com/mislav/vimfiles#readme
[rbenv]: https://github.com/rbenv/rbenv#readme
