#!/usr/bin/env sh

usage () {
  echo "Usage:  polybar.sh [-h|-?|--help] TEMPLATE_FILE BAR_NAME [PLACEHOLDER:REPLACEMENT...]"
  echo ""
  echo "Creates a proper polybar config using TEMPLATE_FILE as a template,"
  echo "replacing PLACEHOLDER's in the template with REPLACEMENT. The bar"
  echo "BAR_NAME is then run."
  exit 0
}

template=""
barname=""

case "$1" in
  -h|-?|--help)
    usage
    ;;
esac

template=$1
shift
barname=$1
shift

if test -z "$template" | test -z "$barname"; then
  usage
fi

scriptfile=$(mktemp)
conffile=$(mktemp)

for arg in "$@"; do
  echo "s/${arg%:*}/${arg#*:}/" >> "$scriptfile"
done
sed -f "$scriptfile" "$template" > "$conffile"

polybar -c "$conffile" "$barname" &
barpid="$!"
trap "kill $barpid; rm -f $scriptfile $conffile; exit" 2 3 9 15
wait
rm -f "$scriptfile" "$conffile"
