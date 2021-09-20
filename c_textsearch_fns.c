#include <stdio.h>
#include <stdlib.h> 
#include "textsearch_fns.h"

int read_line(FILE *in, char *buf) {
    int index = 0;
    char c = fgetc(in);
    //get all characters until you encounter newline/EOF(=-1)/exceed line max
    while (c != -1 && c != '\n')
    {
        //TODO: check to make sure we don't read memory out of bounds
        buf[index] = c;
        if(index < MAXLINE) {
            c = fgetc(in);
            index++;
        } else break;
    }
    //null terminate buffer - even if index = 511 == MAXLINE, not out of bounds
    buf[index] = '\0';
    if(c == EOF) return 0;
    return 1;
}


void print_line(FILE *out, const char *buf) {
    if (out != NULL)
    {
        fprintf(out, "%s\n", buf);
    }
}

unsigned count_occurrences(const char *line, const char *str)
{
    unsigned line_total = 0;

    int str_len = find_string_length(str);
    printf("\nString length of target string = %d\n", str_len);
    //if you search for the empty string
    if(str_len == 0) {
        return 0;
    }

    int line_len = find_string_length(line);
    //only count up to the 512th character, even if string is longer
    if(line_len > 512) line_len = 512;

    int last_index = line_len - str_len;

    printf("For string \"%s\": line len - str len = last index: %d - %d = %d\n\n", str, line_len, str_len, last_index);

    if (last_index < 0) return 0;

    for (int i = 0; i < last_index; i++) {
        char * substr = get_substr(line, str_len, i);
        line_total += strings_equal(substr, str);
        free(substr);
    }
    return line_total;
}

unsigned find_string_length(const char *s)
{
    unsigned len = 0;
    while (s[len] != '\0')
    {
        len++;
    }
    return len;
}

int starts_with(const char *s, const char *pfx) {
    int pfx_len = find_string_length(pfx);
    for(int i = 0; i < pfx_len; i++) {
        if(pfx[i] != s[i]) {
            return 0;
        }
    }
    return 1; //true
}

int strings_equal(const char *s1, const char *s2)
{

    int len1 = find_string_length(s1);
    int len2 = find_string_length(s2);
    if(len1 != len2) return 0;
    // Iterate over the length of the searched word.
    for (int i = 0; i < len1; i++)
    {
        if (s1[i] != s2[i]){
            return 0;
        }
    }
    return 1;
}


unsigned find_all_occurrences(FILE *in, char *search, int printOccurrences)
{
    int has_next_line = 1;
    unsigned num_occurrences = 0;
    unsigned line_total = 0;
    while (has_next_line)
    {
        char *buf = calloc(MAXLINE+1, sizeof(char));
        buf[MAXLINE] = '\0'; 
        //have already checked that in can be opened
        has_next_line = read_line(in, buf); //will be 0 if EOF is encountered
        line_total = count_occurrences(buf, search);
        num_occurrences += line_total;
        if (printOccurrences == 1 && line_total > 0)
        {
            print_line(stdout, buf);
        }
        line_total = 0;
        

       free(buf);
    }
    return num_occurrences;
}


char *get_substr(const char *line, int str_len, int i)
{
    
    char *substr = calloc(str_len, sizeof(char));
    for (int j = 0; j < str_len; j++)
    {
        substr[j] = line[i + j];
    }

    return substr;
}
