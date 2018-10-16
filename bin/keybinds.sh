#!/usr/bin/env sh

#######################
# USAGE:
#
# Extracts all keybinds
# from i3 config and
# pipes them to less
#######################

result=$(python <<END
from pathlib import Path

I3CONFIG = Path(Path.home(), '.config', 'i3', 'config')


def adjust(row, col_width):
    return "".join(word.rstrip().ljust(col_width) for word in row)


result = ""
rows = []
with I3CONFIG.open() as config:
    for line in config:
        if line.startswith('bindsym'):
            line = line.split(' ', 2)
            rows.append(line[1:])
            insert_blank = True
        elif line == "\n" and insert_blank:
            rows.append(["", ""])
        else:
            insert_blank = False

col_width = max(len(row[0]) for row in rows) + 5  # padding
result += adjust(["KEYBINDS", "ACTIONS"], col_width)
result += "\n\n"
for row in rows:
    result += adjust(row, col_width)
    result += "\n"
print(result)
END
)

echo "$result" | less -S -Ps"$(printf "$result" | head -n 1)"
