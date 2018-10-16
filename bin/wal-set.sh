#!/bin/sh

if test "$1" = "-h" || test "$1" = "-?" || test "$1" = "--help"; then
  echo "wal-set.sh - pywal helper to reset environments after wal sets a new theme."
  echo ""
  exit 0
fi

rm -rf $HOME/.themes/wal
rm -rf $HOME/.icons/wal

/opt/oomox/plugins/theme_materia/materia-theme/change_color.sh -o wal $HOME/.cache/wal/colors-oomox
oomox-gnome-colors-icons-cli -o wal $HOME/.cache/wal/colors-oomox

dunst-xres.sh
