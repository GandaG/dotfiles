#!/usr/bin/env sh

db="$HOME/Dropbox/bookmarks/buku_${1}.db"
target="$XDG_DATA_HOME/buku/bookmarks.db"

usage () {
  echo "Usage:  buku-db.sh DATABASE [-rofi]"
  echo ""
  echo "Opens the buku database at ~/Dropbox/bookmarks/buku_DATABASE.db"
  echo "If -rofi is given it runs buku_run instead."
  echo ""
}

if test -e "$db"; then
  shift
else
  usage
  exit 1
fi
if test "$1" = "-rofi"; then
  cmd=buku_run
  shift
else
  cmd=buku
fi
mkdir -p "$(dirname $target)"
ln -fs "$db" "$target"
$cmd $@
rm "$target"
