#include <stdio.h>
#include <stdlib.h>
#include "textsearch_fns.h"

int main(int argc, char **argv)
{
    //initial error handling & try to open file
    if (argc < 3)
    {
        fprintf(stderr, "User did not supply sufficient arguments.");
        exit(1);
    }
    else if (argc > 4)
    {
        fprintf(stderr, "User supplied too many arguments.");
        exit(1);
    }
    else
    {

        FILE *input;
        char *search = argv[argc - 2];
        char *filename = argv[argc - 1];

        int has_c_flag = strings_equal(argv[1], "-c");
        //open user-specified text file to read from
        input = fopen(filename, "r");

        if (input == NULL)
        {
            fprintf(stderr, "File cannot be opened.\n");
            exit(1);
        }

        if (argc == 3 && !has_c_flag)
        {
            //1 = set print occurrences to true
            find_all_occurrences(input, search, 1);
        }
        else if (argc == 4)
        {
            //0 = set print occurrences to false
            printf("%d occurrence(s)\n", find_all_occurrences(input, search, 0));
        }
        else
        {
            fprintf(stderr, "Error!");
            fclose(input);
            exit(1);
        }

        //program ran successfully
        fclose(input);
        exit(0);
    }
}
