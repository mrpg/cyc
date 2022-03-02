#!/bin/sh

set -eu

# The following is useful with web servers like nginx that can
# directly serve gzipped files. See nginx's "gzip_static" directive.

find public -type f |
    while IFS= read -r file
    do
        gzip < "$file" > "$file.gz"
    done

# Upload website to server.

# mv public example.com
# rsync -a example.com mg.sb:/srv/http
# rm -rf example.com

# Etc.
