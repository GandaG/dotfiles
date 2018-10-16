#!/usr/bin/env sh

. "$HOME/.cache/wal/colors.sh"

# how long should the popup remain?
duration=3

#font size
fsize=9

# define geometry
barw=200
barh=25
barx=$(($(screen-size.py -w) / 2 - barw / 2))
bary=10

# colors
bar_bg=${background}
bar_fg=${foreground}

# font used
bar_font_1="FontAwesome5Free:style=Solid:size=${fsize}"
bar_font_2="Inconsolata:style=Regular:size=${fsize}"
bar_font_3="DejavuSans-${fsize}"

# compute all this
baropt="-d -g ${barw}x${barh}+${barx}+${bary} \
  -o 0 -f ${bar_font_1} \
  -o 1 -f ${bar_font_2} \
  -o 0 -f ${bar_font_3} \
  -F${bar_fg} -B${bar_bg}"

#Create the popup and make it live for 3 seconds
(echo -e "${@}"; sleep ${duration}) | lemonbar ${baropt}
