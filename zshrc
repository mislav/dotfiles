# load support for tab completions
autoload -U compinit
compinit -i

autoload colors; colors;
export LSCOLORS="Gxfxcxdxbxegedabagacad"
# setopt auto_cd
# setopt multios
# setopt cdablevarS
setopt prompt_subst

# Find the option for using colors in ls, depending on the version: Linux or BSD
ls --color -d . &>/dev/null 2>&1 && alias ls='ls --color=tty' || alias ls='ls -G'

export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;32'

for file in ~/.shrc/*.sh; do
  source "$file"
done

[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh
