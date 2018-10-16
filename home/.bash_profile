#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

[[ -f ~/.profile ]] && . ~/.profile

systemctl --user import-environment

# autostart x11
if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  startx "$XDG_CONFIG_HOME/X11/xinitrc" > /dev/null 2>&1
fi
