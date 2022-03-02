#!/bin/sh

{
    echo "<ul id='posts'>"

    {
        find -L . -type f -name '*.html' |
            grep -v "index.html\$" |
            while IFS= read -r entry; do
                [ -z "$entry" ] && continue
                mtime=$(cat "$entry.mtime")
                title=$(cat "$entry.title")

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

    echo "</ul>"
} > index.html.posts
