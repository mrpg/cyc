#!/bin/sh

set -eu

# Create .mtime files containing last modification time (for use with
# "{{!!mtime!!}}").

find content -name '*.html' |
    while IFS= read -r file
    do
        if [ ! -f "$file.utime" ]; then
            bin/mtime "$file" > "$file.mtime"
        else
            cp "$file.utime" "$file.mtime"
        fi
    done
