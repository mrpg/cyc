#!/bin/sh

set -eu

meta="../../meta/blog"

{
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
        head -n10 | # only most recent posts are included in RSS
        while IFS= read -r line; do
            path=$(echo "$line" | cut -f2 | sed 's/^\.\///g')
            title=$(echo "$line" | cut -f3)

            echo "<item>"
            echo "<title>$title</title>"

            # note: we omit <pubDate> because it uses the horrific and
            # bloated RFC-822 date format (extreme)

            echo "<link>{{!!base!!}}/$path</link>"
            echo "<guid>{{!!base!!}}/$path</guid>"

            echo "<description>"
            sed 's/<[^>]*>//g' "$path" # removes HTML tags
            echo "</description>"

            # for HTML feeds, replace with:
            # echo "<description><![CDATA[{{##$path##}}]]></description>"

            echo "</item>"
        done
} > "$meta/rss.xml.posts"
