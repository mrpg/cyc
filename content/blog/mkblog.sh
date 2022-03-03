#!/bin/sh

set -eu

meta="../../meta/blog"

{
    echo "<ol id='posts' reversed>"

    {
        find -L . -type f -name '*.html' |
            grep -v "index.html\$" |
            while IFS= read -r entry; do
                [ -z "$entry" ] && continue
                mtime=$(cd ../.. && CYC_FILE="blog/$entry" bin/last_updated.sh) # FIXME: HACK
                title=$(cat "$meta/$entry.title")

                printf '%s\t%s\t%s\n' "$mtime" "$entry" "$title"
            done
    } |
        sort -rn |
        while IFS= read -r line; do
            mtime=$(echo "$line" | cut -f1)
            path=$(echo "$line" | cut -f2)
            title=$(echo "$line" | cut -f3)
            echo "<li><a href='{{##.slab##}}/blog/$path'>$title</a> ($mtime)</li>"
        done

    echo "</ol>"
} > "$meta/index.html.posts"
