#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export EDITOR="vim"
export TERMINAL="st"
export BROWSER="chromium"
setleds -D +num

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  startx
fi
