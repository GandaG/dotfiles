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
