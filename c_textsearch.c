#include <stdio.h>
#include <stdlib.h>
#include "textsearch_fns.h"

/*
 * Description: Main function
 *
 * Parameters:
 *   argc - num. of user provided args 
 *   argv - user provided args
 *
 * Returns:
 *   0 - if program successfully executes.
 *   1 - if user input is invalid
 *   2 - if file cannot be opened
 *   3 - other error
 */
int main(int argc, char **argv)
{
  FILE *input;

      //TODO: remove - debugging print statement
  printf("\nargv[0] = %s, argv[1] = %s, argv[2] = %s, argv[3] = %s\n\n", argv[0], argv[1], argv[2], argv[3]);



  //exit with error code 1 if there's error w number of user args
  if ((argc != 3) && (argc != 4))
  {
    fprintf(stderr, "User arguments are invalid.");
    exit(1);
  }

  //open user-specified text file to read from
  input = fopen(argv[argc - 1], "r");

  //check that file isn't null before reading
  if (input == NULL)
  {
    fprintf(stderr, "File cannot be opened. ");
    fclose(input);
    exit(2);
  }

  //determine whether user wants lines to be printed
  int printOccurrences = (argc == 3)? 1:0;

  //TODO: remove - debugging print statement
  printf("\nargc = %d, printOccurrences = %d\n\n", argc, printOccurrences);

  int num_occurrences = find_all_occurrences(input, argv[argc - 2], printOccurrences);
  //if !printOccurrences -> argv == 4
  if (printOccurrences == 0 && strings_equal(argv[1], "-c"))
  {
    //print num occurrences instead
    fprintf(stdout, "%d occurrence(s)", num_occurrences);
  }

  //program ran successfully
  fclose(input);

  exit(0);
}
