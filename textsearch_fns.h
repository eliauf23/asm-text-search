#ifndef TEXTSEARCH_FNS_H
#define TEXTSEARCH_FNS_H
#include <stdio.h>

#define MAXLINE 511


/*
 * Description: Puts characters from text file until encounters newline or EOF.
 * 
 *
 * Parameters:
 *   in - File pointer.
 *   buf - character buffer to store line.
 *
 * Returns:
 *   0 - EOF
 *   1 - has next line = true
 */
int read_line(FILE *in, char *buf);


/*
 * Description: Prints line of text contained in buf.
 * 
 *
 * Parameters:
 *   out - output file/output stream
 *   buf - buffer with line to print
 *   
 */
void print_line(FILE *out, const char *buf);


/*
 * Description: Count instances of search string in line from text file.
 * 
 *
 * Parameters:
 *   line - line from text file.
 *   str - target string to match.
 *
 * Returns:
 *   number of occurrences of target string
 */
unsigned count_occurrences(const char *line, const char *str);

/*
 * Description: Counts number of characters up to null terminator.
 * 
 *
 * Parameters:
 *   s - string.
 *
 * Returns:
 *   length of string s
 */
unsigned find_string_length(const char *s);


/*
 * Description: Determines if string starts with a certain prefix.
 * 
 *
 * Parameters:
 *   s - string.
 *   pfx - prefix
 *
 * Returns:
 *   0 - false: s does not start with pfx
 *   1 - true: s starts with pfx
 */
int starts_with(const char *s, const char *pfx);

/*
 * Description: Checks equality of two strings.
 * 
 *
 * Parameters:
 *   s1 - string 1.
 *   s2 - string 2.
 * Returns:
 *   0 - if not equal
 *   1 - if equal
 */
int strings_equal(const char *s1, const char *s2);

/*
 * Description: Find number of occurrences in entire text file (and print if argc=3)
 * 
 *
 * Parameters:
 *   in - file ptr.
 *   search - search string
 *   printOccurrences - boolean: if 1, then print matching lines when you find them. 
 *
 * Returns:
 *   unsigned num of occurrences
 */
unsigned find_all_occurrences(FILE* in, char* search, int printOccurrences);

#endif // TEXTSEARCH_FNS_H
