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


# configure git

while true; do
    printf "Enter the name to use with git: "
    read -r git_name
    case $git_name in
        (*[![:blank:]]*) echo "Please enter a valid name.";;
        ("") echo "Please enter a valid name.";;
        (*) git config --global user.name "$git_name"; break;;
    esac
done

while true; do
    printf "Enter the email adress to use with git: "
    read -r git_email
    case $git_email in
        (*[![:blank:]]*) echo "Please enter a valid email address.";;
        ("") echo "Please enter a valid email address.";;
        (*) git config --global user.email "$git_email"; break;;
    esac
done
