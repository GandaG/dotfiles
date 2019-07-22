#!/usr/bin/env bash
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

stty -ixon

shopt -s checkwinsize
shopt -s expand_aliases
shopt -s histappend

xhost +local:root > /dev/null 2>&1

complete -cf sudo

parse_git_branch () {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

export PS1="\$(parse_git_branch)\[\033[0;32m\]\u@\w \\$ \[\033[0m\]"

alias suspend='systemctl suspend'
alias poweroff='systemctl poweroff'
alias reboot='systemctl reboot'

alias more='less'
alias ls='ls -hN --color=auto --group-directories-first'
alias ll='ls -lA'
alias la='ls -A'

alias feh='feh -.'

alias grep='grep --color=always'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'

alias diff='grc diff'
alias du='grc du'
alias env='grc env'
alias fdisk='grc fdisk'
alias gcc='grc gcc'
alias ping='grc ping'
alias ps='grc ps'

alias cp="cp -i"
alias df='df -h'
alias free='free -m'

# gnupg -- ssh
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

# python virtualenvwrapper
export WORKON_HOME="$XDG_DATA_HOME"/.python_virtualenvs
source /usr/bin/virtualenvwrapper_lazy.sh
