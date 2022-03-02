#!/bin/sh

echo "Enter title:"
read -r title

file="$(echo "$title" |
    tr '[:upper:]' '[:lower:]' |
    tr -d '\n' |
    tr -c '[a-zA-Z0-9]._-' '_' |
    head -c20).html"

[ -f "$file" ] && echo "$file already exists." && exit 2

echo "$title" > "$file.title"
edit "$file"
