#!/usr/bin/env sh

wired=
wifi=
noconn=""

check_connection () {
  nc -z 8.8.8.8 53 >/dev/null 2>&1 && return 0 || return 1
}

check_wireless () {
  iwconfig 2>&1 | grep -q ESSID && return 0 || return 1
}

check_connection || (echo "$noconn" && exit)
check_wireless && echo "$wifi" || echo "$wired"
