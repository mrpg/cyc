#!/bin/sh

set -eu

# Create .mtime files containing last modification time (for use with
# "{{!!mtime!!}}").

find content -name '*.html' |
    while IFS= read -r file
    do
        mfile=$(echo "$file" | sed 's/^content/meta/g')
        
        if [ ! -f "$file.utime" ]; then
            bin/mtime "$file" > "$mfile.mtime"

            # Alternatively,
            # git log -n 1 --pretty=format:%ad \
            #   --date=format:'%Y-%m-%d %H:%M' -- "$file" > "$mfile.mtime"
        else
            cp "$file.utime" "$mfile.mtime"
        fi
    done
