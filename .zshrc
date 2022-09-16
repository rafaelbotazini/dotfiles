# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Add Dotnet Core tools directory to path
PATH=$HOME/.dotnet/tools:$PATH

# Add user bin folder to path
PATH=$HOME/.local/bin:$PATH

export PATH=$HOME/bin:/usr/local/bin:$PATH

# XDG Base directories
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CACHE_HOME=$HOME/.cache

export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages 	# Nuget cache
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle

setopt prompt_subst

# Enable autocomplete
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)

ZSH_CONFIG=$HOME/.config/zsh

# Setup history
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$XDG_CACHE_HOME/zsh_history

# Open current dir in ranger with ctrl-o
bindkey -s '^o' 'ranger .\n'

# Open alacritty in current directory
bindkey -s '^t' 'alacritty --working-directory=.\n'

# Aliases
alias ls="ls --color=auto"
alias ip="ip -color=auto"
alias c="clear"
alias z="source ~/.zshrc"
alias update="yay -Syyu --noconfirm"
alias gst="git status"
alias glo="git log --oneline"
alias gdt="git difftool"
alias gpu='git push -u origin $(git branch --show-current)'
alias ssh="TERM=xterm-256color ssh"

local vte=/etc/profile.d/vte.sh

# Make tilix use vte
if [[ -f $vte ]]; then
    . $vte
fi

# Enable colors & set prompt style
autoload -U colors && colors
PS1="[%{$fg_bold[blue]%}%n%{$reset_color%} :: %{$fg[cyan]%}%c%{$reset_color%}"
PS1+='$(git_current_branch)]$ '

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

# Show window titles
preexec() {
    print -Pn "\e]0;$1\a"
}

source $ZSH_CONFIG/directories.zsh
source $ZSH_CONFIG/key-bindings.zsh
source $ZSH_CONFIG/git.zsh
source $ZSH_CONFIG/completion.zsh

if [[ -f ~/.envrc  ]]; then
    source ~/.envrc
fi

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

