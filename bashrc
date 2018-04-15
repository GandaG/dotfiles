#!/usr/bin/env bash
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

stty -ixon

parse_git_branch () {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}
pacman_install () {
  sudo pacman -Syu "$@"
}
pacman_upgrade () {
  sudo pacman -Syu
}
pacman_uninstall () {
  sudo pacman -Rs "$@"
}
aur_install () {
  full_upgrade
  mkdir -pv "$HOME/.aur"
  pushd "$HOME/.aur" >/dev/null 2>&1 || (echo "Failed cd, check bashrc"; return)
  for package in "$@"; do
    git clone "https://aur.archlinux.org/$package.git"
    pushd "$package" >/dev/null 2>&1 || (echo "Failed cd, check bashrc"; return)
    makepkg --noconfirm -sci
    popd >/dev/null 2>&1 || (echo "Failed cd, check bashrc"; return)
  done
  popd >/dev/null 2>&1 || (echo "Failed cd, check bashrc"; return)
}
aur_upgrade () {
  pushd "$HOME/.aur" >/dev/null 2>&1 || (echo "Failed cd, check bashrc"; return)
  for aur in */; do
    pushd "$aur" >/dev/null 2>&1 || (echo "Failed cd, check bashrc"; return)
    echo "Checking ${aur: : -1}..."
    git fetch
    if [ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ] ; then
      echo "----> Updating ${aur: : -1}..."
      git pull
      makepkg --noconfirm -sci
    fi
    popd >/dev/null 2>&1 || (echo "Failed cd, check bashrc"; return)
  done
  popd >/dev/null 2>&1 || (echo "Failed cd, check bashrc"; return)
}
aur_uninstall () {
  pacman_uninstall "$@"
  for package in "$@"; do
    rm -rf "$HOME/.aur/$package"
  done
}
full_upgrade () {
  pacman_upgrade
  aur_upgrade
}

export PS1="\$(parse_git_branch)\[\033[0;32m\]\u@\w \\$ \[\033[0m\]"

alias ls='ls -hN --color=auto --group-directories-first'
alias ll='ls -lA'
alias la='ls -A'

alias grep='grep --color=always'
alias cat='highlight --out-format=xterm256'

alias diff='grc -es --colour=on diff'
alias make='grc -es --colour=on make'
alias gcc='grc -es --colour=on gcc'
alias g++='grc -es --colour=on g++'
alias ping='grc -es --colour=on ping'

alias mute='pamixer -m'
alias unmute='pamixer -u'

# python virtualenvwrapper
export WORKON_HOME=~/.python_virtualenvs
source /usr/bin/virtualenvwrapper_lazy.sh
