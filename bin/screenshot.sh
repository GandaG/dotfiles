#!/usr/bin/env sh

OPTIND=1

dname="$HOME"/Screenshots
fname="$dname/$(date +%s).png"
area=0
upload=0

usage () {
  echo "Usage:  screenshot.sh [-s] [-u]"
  echo ""
  echo "Takes a screenshot and saves it to ~/Screenshots"
  echo "If -s is given, the user is aked for an area to shoot."
  echo "If -u is given, the screenshit is uploaded to imgur"
  echo "using imgur.sh"
  echo ""
}

while getopts "hsu" opt; do
  case "$opt" in
    s)
      area=1
      ;;
    u)
      upload=1
      ;;
    h)
      usage
      exit 0
      ;;
  esac
done

shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

mkdir -p "$dname"
if test $area -eq 1; then
  maim -s $fname
else
  maim $fname
fi
if test $upload -eq 1; then
  imgur.sh "$fname"
  if [ $? -eq 0 ]; then
    notify-send "Screenshot Uploaded" "The screenshot has been successfully uploaded to imgur."
  else
    notify-send "Upload Failed" "The screenshot failed to be uploaded successfully. Check your internet connection."
  fi
fi
