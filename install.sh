#!/usr/bin/env sh

BASEDIR="$(dirname "$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")")"
BACKDIR=$BASEDIR/backups
HOMEDIR=$BASEDIR/home
BINDIR=$BASEDIR/bin
MISCDIR=$BASEDIR/misc
CONFIGDIR=$BASEDIR/config

HOMEDEST="$HOME"
BINDEST="$HOME"/.local/bin
CONFIGDEST="$HOME"/.config

# test_file function
## Checks whether the file is a real file, a symlink or doesn't exist.
## 0: file does not exist
## 1: file is symlink
## 2: file is real
test_file () {
  if [ -L "$1" ]; then
    echo 1
  elif [ -e "$1" ]; then
    echo 2
  else
    echo 0
  fi
}

# link_file function
## Handles all the linking
## arg1: file source path
## arg2: file destination path
## arg3: prefix to commands (like sudo) [optional]
link_file () {
  case $(test_file "$2") in
    2)
      fname=$(basename $2)
      echo "Moving $2 to $BACKDIR/$fname"
      mkdir -p "$BACKDIR"
      $3 mv "$2" "$BACKDIR/$fname"
      ;;
    1)
      # echo "Removing $2"
      $3 rm "$2"
      ;;
  esac
  echo "Creating link at $2"
  $3 ln -s "$1" "$2"
}

# link_all_files function
## Handles all files in a folder
## arg1: Folder where files reside (source)
## args2: Target folder to link to (destination)
link_all_files () {
  mkdir -p "$2"
  for file in "$1"/*; do
    file=$(basename "$file")
    link_file "$1/$file" "$2/$file"
  done
}

shopt -s dotglob

echo "Updating submodules..."
(cd "$BASEDIR" && git submodule init && git submodule update --remote --recursive)
echo

link_all_files "$HOMEDIR" "$HOMEDEST"
echo

link_all_files "$CONFIGDIR" "$CONFIGDEST"
echo

link_all_files "$BINDIR" "$BINDEST"
echo

echo "Setup GnuPG..."
agenthome="$CONFIGDEST"/gnupg/gpg-agent.conf
mkdir -p "$CONFIGDEST"/gnupg
link_file "$MISCDIR/gpg-agent.conf" "$agenthome"
echo

echo "Setup less..."
lesskey "$CONFIGDIR"/less/config
echo

echo "Final configurations..."
source "$HOMEDIR"/.profile
orig_gpg="$HOME"/.gnupg
if [ -d "$orig_gpg" ]; then
    echo "Moving original gnupg files to new location..."
    mv -f "$orig_gpg"/* "$GNUPGHOME"
    rm -rf "$orig_gpg"
fi

shopt -u dotglob
