# This .bash_profile makes loads the non-interactive login features and later
# adds the interactive login features.

# Load the non-interactive login features
[[ -f ~/.bashrc ]] && source ~/.bashrc

source ~/.bash/aliases
source ~/.bash/completions
source ~/.bash/config
source ~/.bash/functions

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export HISTCONTROL=ignoreboth
export HISTIGNORE="ls:exit:pwd:cls:clear"

if [ "$TERM" != "dumb" ]; then
  hash dircolors 2>/dev/null
  if [ $? -eq 0 ]; then
    export LS_OPTIONS='--color=auto'
    eval `dircolors ~/.dir_colors`
  fi
fi
