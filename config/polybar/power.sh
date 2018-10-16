#!/usr/bin/env sh

. "$HOME/.cache/wal/colors.sh"

border_colour=$(echo "$background" | sed -Ee "s/^.{1}/&BB/")
bar_width=210
bar_height=30
font_size=12
width=$(($(screen-size.py -w) / 2 - bar_width))
height=$(($(screen-size.py -h) / 2 - (bar_height / 2)))
template="$(dirname "$(cd "$(dirname "$0")" && pwd -P)/$(basename "$0")")"/powerbar.template

polybar.sh "$template" power \${background}:$background \${foreground}:$foreground \${border_colour}:$border_colour \${font_size}:$font_size \${bar_height}:$bar_height \${height}:$height \${width}:$width
