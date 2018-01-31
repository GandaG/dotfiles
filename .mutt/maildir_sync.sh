#!/usr/bin/env sh

imapserver=$(grep Host < "$HOME"/.mbsyncrc | awk '{print $2}')
netactive=$(ping -c3 "$imapserver" >/dev/null 2>&1 && echo up || echo down)
mailsync="/usr/bin/mbsync"

case "$netactive" in
  'up') "$mailsync" -a;;
  'down');;
esac
