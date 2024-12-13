#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '


if [[ -f ~/.envrc  ]]; then
    source ~/.envrc
fi

if [ -s "$HOME/.asdf/asdf.sh" ]; then
    source $HOME/.asdf/asdf.sh
    # append completions to fpath
    fpath+=${ZDOTDIR:-~}/.zsh_functions
    fpath=(${ASDF_DIR}/completions $fpath)
fi

[ -s "$HOME/.cargo/env" ] && source $HOME/.cargo/env
