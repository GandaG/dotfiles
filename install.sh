#!/usr/bin/env sh

BASEDIR="$(dirname "$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")")"
BACKDIR=$BASEDIR/backups
DOTFILES="bash_profile bashrc calcurse gitconfig mail mailcap mbsyncrc msmtprc mutt taskrc vim vimrc"

echo "Updating submodules..."
(cd "$BASEDIR" && git submodule init && git submodule update --remote)

for file in $DOTFILES; do
  if [ -e "$HOME/.$file" ]; then
    if [ -L "$HOME/.$file" ]; then
      echo "Removing $HOME/.$file"
      rm "$HOME/.$file"
    else
      echo "Moving ""$HOME"/."$file"" to ""$BACKDIR"/."$file"""
      mkdir -p "$BACKDIR"
      mv "$HOME/.$file" "$BACKDIR/.$file"
    fi
  fi

  echo "Creating link at ""$HOME"/."$file"""
  ln -s "$BASEDIR/$file" "$HOME/.$file"
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
