#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char** argv) {
    if (argc != 3) {
        printf("usage: %s string_to_replace file_to_insert < "
                "source_file > output_file\n", argv[0]);
        puts("This command would replace string_to_replace in "
                "source_file with the content of file_to_insert "
                "(except for a trailing newline) and writes the "
                "output to output_file.");
        return EXIT_FAILURE;
    }

    size_t n, j, l = strlen(argv[1]), pos = 0;
    char buf[BUFSIZ], bucket[l];

    while ((n = fread(buf, sizeof(char), BUFSIZ, stdin)) > 0) {
        for (j = 0; j < n; j++) {
            if (buf[j] == argv[1][pos]) {
                bucket[pos] = buf[j];
                pos++;

                if (pos == l) {
                    int hold = 0;
                    char buf2[BUFSIZ];
                    FILE* fp = fopen(argv[2], "rb");
                    size_t m;

                    if (!fp) {
                        fputs("Could not open file.\n", stderr);
                        exit(EXIT_FAILURE);
                    }

                    while ((m = fread(buf2, sizeof(char), BUFSIZ, fp))) {
                        if (hold) {
                            fputc('\n', stdout);
                            hold = 0;
                        }

                        if (buf2[m - 1] == '\n') {
                            m--;
                            hold = 1;
                        }

                        fwrite(buf2, sizeof(char), m, stdout);
                    }

                    fclose(fp);
                    pos = 0;
                }
            }
            else {
                fwrite(bucket, sizeof(char), pos, stdout);
                fputc(buf[j], stdout);
                pos = 0;
            }
        }
    }

    return EXIT_SUCCESS;
}
