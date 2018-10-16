#!/usr/bin/env bash
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

stty -ixon

parse_git_branch () {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

export PS1="\$(parse_git_branch)\[\033[0;32m\]\u@\w \\$ \[\033[0m\]"

alias suspend='systemctl suspend'
alias poweroff='systemctl poweroff'
alias reboot='systemctl reboot'

alias ls='ls -hN --color=auto --group-directories-first'
alias ll='ls -lA'
alias la='ls -A'

alias mbsync='mbsync -c "$XDG_CONFIG_HOME"/isync/mbsyncrc'
alias msmtp='msmtp -C "$XDG_CONFIG_HOME"/msmtp/msmtprc'

alias feh='feh -.'

alias grep='grep --color=always'

alias diff='grc -es --colour=on diff'
alias make='grc -es --colour=on make'
alias gcc='grc -es --colour=on gcc'
alias g++='grc -es --colour=on g++'
alias ping='grc -es --colour=on ping'

alias mute='pamixer -m'
alias unmute='pamixer -u'

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

# handle terminal colours
(cat ~/.cache/wal/sequences &)
source ~/.cache/wal/colors-tty.sh
