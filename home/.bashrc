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

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
use_color=false
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
if ${use_color} ; then
    if type -P dircolors >/dev/null ; then
        if [[ -f ~/.dir_colors ]] ; then
            eval $(dircolors -b ~/.dir_colors)
        elif [[ -f /etc/DIR_COLORS ]] ; then
            eval $(dircolors -b /etc/DIR_COLORS)
        fi
    fi
fi
unset use_color safe_term match_lhs sh
