#include <stdio.h>
#include <stdlib.h>
#include "textsearch_fns.h"
#include <string.h> 
//remove str.h just using for moment

/*
 * Description: Main function
 *
 * Parameters:
 *   argc - num. of user provided args 
 *   argv - user provided args
 *
 * Returns:
 *   0 - if program successfully executes.
 *   1 - if user input is invalid or file cannot be opened
 */
int main(int argc, char **argv)
{
    FILE *input;
    char *search = argv[argc - 2];

    int filename_idx = argc - 1;

    //error types - check down below
    int too_few_args = argc < 3;
    int too_many_args = argc > 4;
    int has_c_flag = strings_equal(argv[1], "-c");

    int num_occurrences = 0;

    //initial error handling & try to open file
    if (too_few_args)
    {
        fprintf(stderr, "User did not supply sufficient arguments.");
        exit(1);
    } else if(too_many_args) {
        fprintf(stderr, "User supplied too many arguments.");
        exit(1);
    }
    else
    {
        //open user-specified text file to read from
        input = fopen(argv[filename_idx], "r");

        if (input == NULL)
        {
            fprintf(stderr, "File cannot be opened. ");
            fclose(input);
            exit(1);
        }
    }

    if (argc == 3 && !has_c_flag)
    {
        //1 = set print occurrences to true
        num_occurrences = find_all_occurrences(input, search, 1);
    }
    else if (argc == 4 && has_c_flag)
    {
        //0 = set print occurrences to false
        num_occurrences = find_all_occurrences(input, search, 0);
        fprintf(stdout, "%d occurrence(s)", num_occurrences);
    } else {
        fprintf(stderr, "Error!");
        exit(1);
    }
    

    //program ran successfully
    fclose(input);
    exit(0);
}
