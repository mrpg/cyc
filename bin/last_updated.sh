#!/bin/sh

set -eu

file="content/$CYC_FILE"
mfile="meta/$CYC_FILE"

if [ ! -f "$mfile.utime" ]; then
    bin/mtime "$file"

    # Alternatively,
    # git log -n 1 --pretty=format:%ad \
    #   --date=format:'%Y-%m-%d %H:%M' -- "$file"
else
    cat "$mfile.utime"
fi
