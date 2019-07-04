#
# ~/.profile
#

export LOCAL_BIN="$HOME"/.local/bin
export PATH=$PATH:$LOCAL_BIN
export EDITOR="vim"
export VISUAL="vim"
export TERMINAL="xfce4-terminal"
export BROWSER="firefox"

# QT
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_AUTO_SCREEN_SCALE_FACTOR=0

# xdg
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_CACHE_HOME="$HOME"/.cache
export XDG_DATA_HOME="$HOME"/.local/share

# GnuPG
export GNUPGHOME="$XDG_CONFIG_HOME"/gnupg

# GTK
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc

# gradle
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle

# less
export LESSKEY="$XDG_CONFIG_HOME"/less/lesskey
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history

# notmuch
export NOTMUCH_CONFIG="$XDG_CONFIG_HOME"/notmuch/notmuchrc

# pass
export PASSWORD_STORE_DIR="$HOME"/Sync/password_store
export PASSWORD_STORE_GIT="$HOME"/Sync/password_store

# python
export PYTHONSTARTUP="$XDG_CONFIG_HOME"/python/startup.py

# readline
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc

# vim
export VIMINIT=":source $XDG_CONFIG_HOME"/vim/vimrc

# wget
export WGETRC="$XDG_CONFIG_HOME"/wgetrc

# wine
export WINEPREFIX="$XDG_DATA_HOME"/wineprefixes/default
