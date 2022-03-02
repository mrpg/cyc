CC = cc
CFLAGS = -Os -s -std=c99 -pedantic -Wall

all: replace mtime

replace: replace.c
	$(CC) $(CFLAGS) -oreplace replace.c

mtime: mtime.c
	$(CC) $(CFLAGS) -D_XOPEN_SOURCE=500 -omtime mtime.c

clean:
	rm -f replace mtime
