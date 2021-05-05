# load support for tab completions
autoload -U compinit
compinit -i
zstyle ':completion:*' menu select

autoload colors
colors

export LSCOLORS="Gxfxcxdxbxegedabagacad"
# Find the option for using colors in ls, depending on the version: Linux or BSD
ls --color -d . >/dev/null 2>&1 && alias ls='ls --color=tty' || alias ls='ls -G'

export GREP_OPTIONS='--color=auto'

for file in ~/.shrc/*.sh; do
  source "$file"
done

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
