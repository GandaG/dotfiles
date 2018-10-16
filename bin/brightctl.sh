#!/usr/bin/env bash
#
#   Script used to change bright level.
#
#   REQUIRES: xbacklight, lemonbar (popup alias)
#################################################################################

bright_step=10

usage () {
  echo "Usage:  brightctl.sh ARG"
  echo ""
  echo "Controls screen brightness. If ARG is 0 reduces brightness"
  echo "by 10, if ARG is 1 increases brightness by 10."
  echo ""
}

cur_bright () {
  printf "%.*f\n" 0 $(xbacklight -get)
}

function send_notify(){
    cur_bri="$(cur_bright)"
      bri_text="%{c}%{T1}\uf185%{T3} " # Add bright icon
      for block in $(seq 0 9); do
        let math_blk=$block*${bright_step}
        if [[ $math_blk -lt $cur_bri ]]; then
          bri_text="${bri_text}\u25aa"    # Filled small square
        else
          bri_text="${bri_text}\u25ab"    # Empty small square
        fi
      done
    popup.sh "${bri_text} %{T2}${cur_bri}"
}

if [[ $1 == 1 ]]; then
  xbacklight -set $(($(cur_bright)+bright_step))
elif [[ $1 == 0 ]]; then
  xbacklight -set $(($(cur_bright)-bright_step))
else
  usage
  exit 1
fi

send_notify
