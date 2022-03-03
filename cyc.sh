#!/bin/sh

set -eu

apply_exec () {
    # Replace execution marks with the output of the command in file
    # $1, where $2 is the root name of the file.

    tmpout=$(mktemp)

    cp "$1" "$tmpout"

    execs=$(grep -o "{{^^[^}]*^^}}" "$tmpout" |
        sort |
        uniq |
        sed 's/\^//g' | sed 's/{//g' | sed 's/}//g')

    echo "$execs" |
        while IFS= read -r one_exec
        do
            [ -z "$one_exec" ] && continue
            cmdout=$(mktemp)

            echo "CYC_EXEC: '$one_exec' ($2)..." >&2
            (
                export CYC_FILE=$2

                exec "$one_exec"
            ) > "$cmdout" || {
                bail 2 "Error: Could not run '$one_exec'. Does it contain a space? Commands may not have arguments in cyc templates. You should write a shell script that can be called in a standalone manner."
            }

            replace_in_place "$tmpout" "{{^^""$one_exec""^^}}" "$cmdout"
            rm -f "$cmdout"
        done

    mv "$tmpout" "$1"
}

apply_includes () {
    # Replace inclusion marks ("includes") with the referenced file in
    # file $1, where $2 is a preferred search path for included files.
    # If $2/included does not exist, attempt to use template/included, etc.

    tmpout=$(mktemp)

    cp "$1" "$tmpout"

    includes=$(grep -o "{{##[^}]*##}}" "$tmpout" |
        sort |
        uniq |
        sed 's/#//g' | sed 's/{//g' | sed 's/}//g')

    echo "$includes" |
        while IFS= read -r one_include
        do
            [ -z "$one_include" ] && continue

            origin="$2/$one_include"
            [ -f "$origin" ] || origin="meta/$one_include"
            [ -f "$origin" ] || origin="template/$one_include"
            [ -f "$origin" ] || origin="static/$one_include"
            [ -f "$origin" ] || origin="$one_include"

            [ -f "$origin" ] || {
                bail 2 "Error: Included file $one_include not found (last checked: $origin)."
            }

            replace_in_place "$tmpout" "{{##""$one_include""##}}" "$origin"
        done

    mv "$tmpout" "$1"
}

apply_once () {
    # Merge (body) file content/$1 into template $2, with output written
    # to public/$1. This function loops until no fields or includes are
    # left in the resulting file.

    target="public/$1"

    cp "$2" "$target"

    while needs_templating "$target"
    do
        fields=$(grep -o "{{!![^}]*!!}}" "$target" |
            sort |
            uniq |
            sed 's/{{!!//g' | sed 's/!!}}//g')

        echo "$fields" |
            while IFS= read -r one_field
            do
                [ -z "$one_field" ] && continue
                [ "$one_field" = "body" ] && continue

                origin="meta/$1.$one_field"
                [ -f "$origin" ] || origin="content/$1.$one_field"

                [ -f "$origin" ] || {
                    bail 3 "Error: $origin was not found in content/ or meta/."
                }

                replace_in_place "$target" "{{!!""$one_field""!!}}" "$origin"
            done

        replace_in_place "$target" "{{!!body!!}}" "content/$1"

        apply_includes "$target" "$(dirname "content/$1")"
        apply_exec "$target" "$1"
    done
}

bail () {
    # Fail with exit code $1 and message $2

    rm -rf public
    echo "$2" 1>&2
    exit "$1"
}

extension () {
    # Ascertain the extensions of the filenames in stdin

    rev | cut -d'.' -f1 | rev
}

needs_templating () {
    # Returns a non-failing exit code if file $1 includes fields or
    # includes.

    {
        grep "{{!![^}]*!!}}" "$1" || grep -o "{{##[^}]*##}}" "$1"
    } > /dev/null 2>&1
}

replace_in_place () {
    # In-place replace the string $2 with the contents of file $3,
    # in file $1. Note that bin/replace works with stdin/stdout.

    tmpf=$(mktemp)

    bin/replace "$2" "$3" < "$1" > "$tmpf"
    mv "$tmpf" "$1"
}

resolve_template () {
    # Find the template that should be applied to $1. First, checks if
    # {meta/,content/}$1.template exists. If not, check for default
    # templates first in any corresponding subdirectory of template/, then
    # in the parent directories.

    cfile="content/$1"
    mfile="meta/$1"
    ext=$(echo "$1" | extension)

    [ -f "$mfile.template" ] && cat "$mfile.template" && return 0
    [ -f "$cfile.template" ] && cat "$cfile.template" && return 0

    while :
    do
        cfile=$(dirname "$cfile")
        candidate="$(echo "$cfile" | sed 's/^content//g')/default.$ext"
        [ -f "template/$candidate" ] && echo "$candidate" && return 0

        [ "$cfile" = "content" ] && break
    done

    echo "default.$ext" && return 1
}

unext () {
    # Remove extensions from the filenames in stdin

    rev | cut -d'.' -f2- | rev
}

[ -d content ] || bail 4 "content does not exist."
[ -d template ] || bail 5 "template does not exist."

rm -rf public

# Copy static files to destination
[ -d static ] && cp -LR static public

# Re-create directory hierarchy of content/ in destination
find -L content -type d |
    grep -v "^content\$" |
    cut -d'/' -f2- |
    while IFS= read -r sub
    do
        mkdir -p "public/$sub"
    done

# To each file in content/, apply template
for pattern in "$@"
do
    find -L content -type f -name "$pattern" |
        cut -d'/' -f2- |
        while IFS= read -r source
        do
            [ -z "$source" ] && continue

            template=$(resolve_template "$source")

            [ -f "template/$template" ] && \
                apply_once "$source" "template/$template"
        done
done
