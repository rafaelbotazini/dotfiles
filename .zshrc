# Add Dotnet Core tools directory to path
PATH=$HOME/.dotnet/tools:$PATH

export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/rafael/.config/oh-my-zsh"

# ZSH theme config
ZSH_THEME=""
TYPEWRITTEN_PROMPT_LAYOUT="singleline_verbose"
TYPEWRITTEN_CURSOR="block"
TYPEWRITTEN_SYMBOL="λ"

#ZSH plugins
plugins=(
	git
)

# Source oh-my-zsh functions
source $ZSH/oh-my-zsh.sh

PROMPT='[%{$fg_bold[blue]%}%n%{$reset_color%}@%{$fg_bold[green]%}%m%{$reset_color%} %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)%{$reset_color%}]$ '

ZSH_THEME_GIT_PROMPT_PREFIX="(%{$fg_bold[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%} %{$fg[yellow]%}%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%}"

# XDG Base directories
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CACHE_HOME=$HOME/.cache
export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages 	# Nuget cache

# Aliases
alias ip="ip -color=auto"
alias c="clear"
alias z="source ~/.zshrc"
alias update="yay -Syyu"

# Make tilix use vte
. /etc/profile.d/vte.sh

# Color hack for man pages
man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}


