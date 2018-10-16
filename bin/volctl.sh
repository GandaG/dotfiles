#!/usr/bin/env bash
#
#   Script used to change volume level.
#
#   REQUIRES: pamixer, lemonbar (popup alias)
#################################################################################

volume_step=10

usage () {
  echo "Usage:  volctl.sh ARG"
  echo ""
  echo "Controls volume. If ARG is 0 reduces volume"
  echo "by 10, if ARG is 1 increases volume by 10."
  echo ""
}

function send_notify(){
    cur_vol="$(pamixer --get-volume)"
    if [[ $(pamixer --get-mute) == "true" ]]; then
        vol_text="%{c}%{T1}\uf026 %{T3} "
        for block in $(seq 0 9); do
            vol_text="${vol_text}\u25ab"
        done
    else
        vol_text="%{c}%{T1}\uf028%{T3} " # Add volume icon
        for block in $(seq 0 9); do
            let math_blk=$block*${volume_step}
            if [[ $math_blk -lt $cur_vol ]]; then
                vol_text="${vol_text}\u25aa"    # Filled small square
            else
                vol_text="${vol_text}\u25ab"    # Empty small square
            fi
        done
    fi
    popup.sh "${vol_text} %{T2}${cur_vol}"
}

if [[ $1 == 1 && $(pamixer --get-volume) -lt 100 ]]; then
  pamixer -ui $volume_step
elif [[ $1 == 0 ]]; then
  if [ $(pamixer --get-volume) -gt 15 ]; then
    pamixer -u
  else
    pamixer -m
  fi
  pamixer -d $volume_step
elif [[ $1 == -1 ]]; then
  if [ "$(pamixer --get-volume)" -lt 5 ] && [ "$(pamixer --get-mute)" = "true" ]; then
    pamixer -ui $volume_step
  else
    pamixer -t
  fi
else
  usage
  exit 1
fi

send_notify
