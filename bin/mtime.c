#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

int main(int argc, char** argv) {
    struct stat statbuf;
    struct tm* tm = NULL;
    char buf[17];

    if (argc != 2) {
        printf("usage: %s file\n", argv[0]);
        puts("This command would print the mtime of file.");
        return EXIT_FAILURE;
    }

    if (stat(argv[1], &statbuf) == 0 &&
        (tm = localtime(&(statbuf.st_mtime))) != NULL &&
        strftime(buf, 64, "%Y-%m-%d %H:%M", tm) == 16) {
        puts(buf);
    }
    else {
        return EXIT_FAILURE;
    }
}
