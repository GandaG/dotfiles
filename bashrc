#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

stty -ixon

parse_git_branch () {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}
aur_install () {
  mkdir -pv ~/.aur
  pushd ~/.aur >/dev/null 2>&1
  git clone https://aur.archlinux.org/$1.git
  pushd $1 >/dev/null 2>&1
  makepkg --noconfirm -sci
  popd >/dev/null 2>&1
  popd >/dev/null 2>&1
}
aur_upgrade () {
  pushd ~/.aur >/dev/null 2>&1
  for aur in */; do
    pushd $aur >/dev/null 2>&1
    echo "Checking ${aur: : -1}..."
    git fetch
    if [ $(git rev-parse HEAD) != $(git rev-parse @{u}) ] ; then
      echo "----> Updating ${aur: : -1}..."
      git pull
      makepkg --noconfirm -sci
    fi
    popd >/dev/null 2>&1
  done
  popd >/dev/null 2>&1
}

export PS1="\$(parse_git_branch)\[\033[0;32m\]\u@\w \\$ \[\033[0m\]"

alias ls='ls -hN --color=auto --group-directories-first'
alias ll='ls -lA'
alias la='ls -A'

alias grep='grep --color=always'
alias cat='highlight --out-format=xterm256'

alias diff='grc -es --colour=auto diff'
alias make='grc -es --colour=auto make'
alias gcc='grc -es --colour=auto gcc'
alias g++='grc -es --colour=auto g++'
alias ping='grc -es --colour=auto ping'

alias mute='pamixer -m'
alias unmute='pamixer -u'
