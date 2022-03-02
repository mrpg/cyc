#!/bin/sh

set -eu

# Create .mtime files containing last modification time (for use with
# "{{!!mtime!!}}").

find content -name '*.html' |
    while IFS= read -r file
    do
        bin/mtime "$file" > "$file.mtime"
    done
