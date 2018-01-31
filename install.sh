#!/usr/bin/env sh

BASEDIR="$(dirname "$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")")"
OLDDIR="$BASEDIR"_old
DOTFILES="$BASEDIR/.*"
IGNOREFILES=". .. .git .gitignore .gitattributes .gitmodules"

echo "Updating submodules..."
(cd "$BASEDIR" && git submodule init && git submodule update --remote)

for file in $DOTFILES; do
  filetoignore=0
  for filename in $IGNOREFILES; do
    if [ "$filename" = "$(basename "$file")" ]; then
      filetoignore=1
      break
    fi
  done
  if [ "$filetoignore" -eq 1 ]; then
    continue
  fi

  if [ -e "$HOME/$(basename "$file")" ]; then
    if [ -L "$HOME/$(basename "$file")" ]; then
      rm "$HOME/$(basename "$file")"
    else
      echo "Moving ""$HOME"/"$(basename "$file")"" to ""$OLDDIR"/"$(basename "$file")"""
      mkdir -p "$OLDDIR"
      mv "$HOME/$(basename "$file")" "$OLDDIR/$(basename "$file")"
    fi
  fi

  echo "Creating link at ""$HOME"/"$(basename "$file")"""
  ln -s "$file" "$HOME/$(basename "$file")"
done


# Setup email password
agenthome="$HOME"/.gnupg/gpg-agent.conf
mkdir -p "$HOME"/.gnupg
if [ -e "$agenthome" ]; then
  if [ -L "$agenthome" ]; then
    rm "$agenthome"
  else
    mv "$agenthome" "$OLDDIR"/gpg-agent.conf
  fi
fi
ln -s "$BASEDIR"/gpg-agent.conf "$agenthome"
echo
echo "Enter email password to encrypt. Press Enter+Ctrl-D to finish..."
gpg2 --encrypt --yes -o "$HOME"/.gnupg/.email-password.gpg -r daniel.henri.nunes@gmail.com -

echo "Running initial maildir sync..."
mbsync -a

echo "Adding mail sync job to crontab..."
tmpfile=$(mktemp)
crontab -l > "$tmpfile"
grep "$HOME/.mutt/maildir_sync.sh" "$tmpfile" || echo "*/1 * * * * $HOME/.mutt/maildir_sync.sh" >> "$tmpfile"
crontab "$tmpfile"
rm "$tmpfile"
