#!/usr/bin/env sh

BASEDIR=$(dirname "$0")
OLDDIR="$BASEDIR"_old
DOTFILES="$BASEDIR/.*"
IGNOREFILES=".git .gitignore .gitattributes"

for file in $DOTFILES; do
    for filename in $IGNOREFILES; do
        if [ "$filename" = "$(basename "$file")" ]; then
            continue
        fi
    done
    if [ -f "$HOME/$(basename "$file")" ]; then
        mv "$HOME/$(basename "$file")" "$OLDDIR/$(basename "$file")"
    else
        ln -s "$file" "$HOME/$file"
    fi
done
