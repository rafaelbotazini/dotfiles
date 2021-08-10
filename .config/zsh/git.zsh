# The git prompt's git commands are read-only and should not interfere with
# other processes. This environment variable is equivalent to running with `git
# --no-optional-locks`, but falls back gracefully for older versions of git.
# See git(1) for and git-status(1) for a description of that flag.
#
# We wrap in a local function instead of exporting the variable directly in
# order to avoid interfering with manually-run git commands by the user.
function __git_prompt_git() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

# Outputs the name of the current branch
# Usage example: git pull origin $(git_current_branch)
# Using '--quiet' with 'symbolic-ref' will not cause a fatal error (128) if
# it's not a symbolic ref, but in a Git repo.
function git_current_branch() {
  local ref
  ref=$(__git_prompt_git symbolic-ref --quiet HEAD 2> /dev/null)

  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null) || return
  fi

  local git_status=$(__git_prompt_git status --porcelain 2> /dev/null | tail -1)

  local branch_info=" ("

  if [[ -z $git_status ]]; then
    branch_info+="%{$fg_bold[green]%}${ref#refs/heads/}%{$reset_color%}"
  else
    branch_info+="%{$fg_bold[red]%}${ref#refs/heads/}%{$reset_color%}"
  fi

  branch_info+=")"

  echo $branch_info
}


