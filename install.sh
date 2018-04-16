#!/usr/bin/env sh

BASEDIR="$(dirname "$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")")"
BACKDIR=$BASEDIR/backups
DOTFILES="bash_profile bashrc calcurse gitconfig mail mailcap mbsyncrc msmtprc mutt ncmpcpp taskrc vim vimrc"
CONF=$HOME/.config
CONFIGFOLDER=$BASEDIR/config

# test_file function
## Checks whether the file is a real file, a symlink or doesn't exist.
## 0: file does not exist
## 1: file is symlink
## 2: file is real
test_file () {
  if [ -L $1 ]; then
    echo 1
  elif [ -e $1 ]; then
    echo 2
  else
    echo 0
  fi
}

echo "Updating submodules..."
(cd "$BASEDIR" && git submodule init && git submodule update --remote)

for file in $DOTFILES; do
  case $(test_file "$HOME/.$file") in
    2)
      echo "Moving ""$HOME"/."$file"" to ""$BACKDIR"/."$file"""
      mkdir -p "$BACKDIR"
      mv "$HOME/.$file" "$BACKDIR/.$file"
      ;;
    1)
      echo "Removing $HOME/.$file"
      rm "$HOME/.$file"
      ;;
  esac
  echo "Creating link at ""$HOME"/."$file"""
  ln -s "$BASEDIR/$file" "$HOME/.$file"
done

mkdir -p $CONF
for folder in $CONFIGFOLDER/*; do
  folder=$(basename $folder)
  case $(test_file "$CONF/$folder") in
    2)
      echo "Moving $CONF/$folder to $BACKDIR/$folder"
      mkdir -p $BACKDIR
      mv "$CONF/$folder" "$BACKDIR/$folder"
      ;;
    1)
      echo "Removing $CONF/$folder"
      rm "$CONF/$folder"
      ;;
  esac
  echo "Creating link at $CONF/$folder"
  ln -s "$CONFIGFOLDER/$folder" "$CONF/$folder"
done

# Setup email password
agenthome="$HOME"/.gnupg/gpg-agent.conf
mkdir -p "$HOME"/.gnupg
if [ -e "$agenthome" ]; then
  if [ -L "$agenthome" ]; then
    rm "$agenthome"
  else
    mkdir -p "$BACKDIR"
    mv "$agenthome" "$BACKDIR"/gpg-agent.conf
  fi
fi
ln -s "$BASEDIR"/gpg-agent.conf "$agenthome"
echo
echo "Enter email password to encrypt. Press Enter+Ctrl-D to finish..."
gpg2 --encrypt --yes -o "$HOME"/.gnupg/.email-password.gpg -r daniel.henri.nunes@gmail.com -

echo "Adding mail sync job to crontab..."
tmpfile=$(mktemp)
crontab -l > "$tmpfile"
grep "$HOME/.mutt/maildir_sync.sh" "$tmpfile" || echo "*/1 * * * * $HOME/.mutt/maildir_sync.sh" >> "$tmpfile"
crontab "$tmpfile"
rm "$tmpfile"
