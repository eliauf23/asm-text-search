#include <stdio.h>
#include <stdlib.h>
#include <string.h> // these functions may be used in the test program
#include "textsearch_fns.h"
#include "tctest.h"

typedef struct {
    const char *pandp;
    const char *palindromes;
    const char *maxline_513;
    const char *maxline_b;
    const char *maxline_512;
    const char *empty;
    const char *justnewline;
    const char *justEOF;
    const char *randomAlphanumeric;
} TestObjs;


TestObjs *setup(void);
void cleanup(TestObjs *objs);

// TODO: declare test functions

void test_read_line(TestObjs *objs);
void test_print_line(TestObjs *objs);
void test_count_occurrences(TestObjs *objs);
void test_find_string_length(TestObjs *objs);
void test_starts_with(TestObjs *objs);
void test_strings_equal(TestObjs *objs);
void test_find_all_occurrences(TestObjs *objs);
void test_get_substr(TestObjs *objs);

int main(int argc, char **argv) {
    // Allow the name of the test function to execute to be specified
    // on the command line
    if (argc > 1) {
        tctest_testname_to_execute = argv[1];
    }

    TEST_INIT();


    TEST(test_read_line);
    TEST(test_print_line);
    TEST(test_count_occurrences);
    TEST(test_find_string_length);
    TEST(test_starts_with);
    TEST(test_strings_equal);
    TEST(test_find_all_occurrences);
    TEST(test_get_substr);


    TEST_FINI();

    return 0;
}


TestObjs *setup(void) {
    TestObjs *objs = malloc(sizeof(TestObjs));

    objs->pandp =
        "It is a truth universally acknowledged, that a single man in\n"
        "possession of a good fortune, must be in want of a wife.\n"
        "\n"
        "However little known the feelings or views of such a man may be\n"
        "on his first entering a neighbourhood, this truth is so well\n"
        "fixed in the minds of the surrounding families, that he is\n"
        "considered as the rightful property of some one or other of their\n"
        "daughters.\n";
    //3 occurrences of racecar
    objs->palindromes = "racecaracecaracecar";
    //512 a's followed by 1 b and \n
    objs->maxline_513 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab\n";
    //515 chars
    objs->maxline_b = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaastar\n";
    //510 chars and \n
    objs->maxline_512 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab\n";
    objs->empty = "";
    objs->justnewline = "\n";
    objs->justEOF = EOF;
    objs->randomAlphanumeric =
    "itfm92jH2m9UxobL7\n"
       "38VwNhd8Fsx7tQnx7\n"
       "tnlUIHoaNL08hxEa7\n"
       "12KSL9o5ZiZHV3uI7\n"
       "T9BnNTzApkWWmpl47\n"
       "DnieX417IjGr5Q1a7\n"
       "uFkxxqoU0i6PZwVw7\n"
       "7FzAE5N3favxZ7TM7\n"
       "tiv0oiBjRqybLojc7\n"
       "yXxwXcxXgkHS7Apt7\n"
       "NTc4XjrOXOHp6qj87\n"
       "yKfHUgqmwcPOmKn17\n"
       "nb2ujNFZLVGW60kH7\n"
       "eZfpjnr4Z88a7WEd7\n"
       "5oFa2UkgNLD8dBSf7\n"
       "LSyzDoROjNrVa6pz7\n"
       "sr9rr7GwJ3d64Kvi7\n"
       "zdzTIn1zvtY40Rpb7\n"
       "JqtLoBjhcXkAjFZe7\n"
       "CPIyPXcgxZB67rpJ\n";  

        return objs;
}

void cleanup(TestObjs *objs) {
    free(objs);
}

// An example test function

void test_read_line(TestObjs *objs) {
    // the fmemopen function allows us to treat a character string
    // as an input file
    FILE *in = fmemopen((char *) objs->pandp, strlen(objs->pandp), "r");
    char buf[MAXLINE + 1];

    ASSERT(read_line(in, buf));
    ASSERT(0 == strcmp(buf, "It is a truth universally acknowledged, that a single man in"));

    ASSERT(read_line(in, buf));
    ASSERT(0 == strcmp(buf, "possession of a good fortune, must be in want of a wife."));

    ASSERT(read_line(in, buf));
    ASSERT(0 == strcmp(buf, ""));

    ASSERT(read_line(in, buf));
    ASSERT(0 == strcmp(buf, "However little known the feelings or views of such a man may be"));

    ASSERT(read_line(in, buf));
    ASSERT(0 == strcmp(buf, "on his first entering a neighbourhood, this truth is so well"));

    ASSERT(read_line(in, buf));
    ASSERT(0 == strcmp(buf, "fixed in the minds of the surrounding families, that he is"));

    ASSERT(read_line(in, buf));
    ASSERT(0 == strcmp(buf, "considered as the rightful property of some one or other of their"));

    ASSERT(read_line(in, buf));
    ASSERT(0 == strcmp(buf, "daughters."));

    // at this point we have read the last line
    ASSERT(!read_line(in, buf));

    fclose(in);

    //edge case return 0 if there is a next line, non zero value when you encounter EOF
    //TODO: Make sure we get the proper return value

    //TODO: empty file or just /n want to make sure returns right thing    
}

// TODO: implementations of other test functions

void test_print_line(TestObjs *objs) {
    //TODO: implement (print various lines print properly)

    //only ever use it for stoud and by def not null
}


void test_count_occurrences(TestObjs *objs) {

    FILE *in_1 = fmemopen((char *) objs->pandp, strlen(objs->pandp), "r");
    char bufa[MAXLINE + 1];

    //simple case
    ASSERT(count_occurrences(read_line(in_1, bufa), "truth") == 1);

    //checking case sensitivity 1
    ASSERT(count_occurrences(read_line(in_1, bufa), "Good") == 0);

    // just newline char
    ASSERT(count_occurrences(read_line(in_1, bufa), "NA") == 0);

    //ignores punctuation 
    //line reads in text "neighbourhood, this"
    ASSERT(count_occurrences(read_line(in_1, bufa), "neighbourhood this") == 1);

    //testing multiple occurances of substrings
    ASSERT(count_occurrences(read_line(in_1, bufa), "is") == 2);

    //spacing test
    ASSERT(count_occurrences(read_line(in_1, bufa), "s o m e") == 0);
    
    fclose(in_1);

    //testing letters after char limit
    FILE *in_2 = fmemopen((char *) objs->maxline_513, strlen(objs->maxline_513), "r");
    char bufb[MAXLINE + 1];

    ASSERT(count_occurrences(read_line(in_2, bufb), "b") == 0);

    fclose(in_2);

    //testing word that goes over the char limit
    FILE *in_3 = fmemopen((char *) objs->maxline_b, strlen(objs->maxline_b), "r");
    char bufc[MAXLINE + 1];

    ASSERT(count_occurrences(read_line(in_3, bufc), "star") == 0);

    fclose(in_3);

   
    //TODO: MAXLINE (right before char, after max line char)
    //3-4 random cases with the alphanumeric

}


void test_find_string_length(TestObjs *objs) {

    // empty string
    ASSERT(find_string_length(objs->empty) == 0);

    //new line
    ASSERT(find_string_length(objs->justnewline) == 0);

    //maxline_513 len = 513
    ASSERT(find_string_length(objs->maxline_513) == 512);

    //512 bc should only read up to 512 chars
    ASSERT(find_string_length(objs->maxline_513) == 512);

    //random
    ASSERT(find_string_length(objs->palindromes) == 19);

    //line from pandp
    ASSERT(find_string_length("considered as the rightful property of some one or other of their\n") == 65);

}


void test_starts_with(TestObjs *objs) {

    //simple true check
    ASSERT(starts_with("wordalala", "wor") == 1);

    //simple false check
    ASSERT(starts_with("wordalala", "not") == 0);

    //prefix is longer than string
    ASSERT(starts_with("wor", "wordalala") == 0);

    //words are equal
    ASSERT(starts_with("word", "word") == 1);
    
}


void test_strings_equal(TestObjs *objs) {
//int strings_equal(const char *s1, const char *s2)
// 1 = true, 0 = false

    //simple true
    ASSERT(strings_equal("abc", "abc") == 1);

    //simple false
    ASSERT(strings_equal("abc", "def") == 0);

    //similar strings
    ASSERT(strings_equal("hi my name is Rosie", "hi my age is Rosie") == 0);

    //smae but w/ space
    ASSERT(strings_equal("welcome", "wel come") == 0);

    //newline char
    ASSERT(strings_equal("yXxwXcxXgkHS7Apt7\n", "yXxwXcxXgkHS7Apt7") == 1);

    //string literals, not equals, same beginning/same ending, prefix and suffix, palendromes, 
}

void test_find_all_occurrences(TestObjs *objs) {
    //TODO: implement
    //pass output, and string and make sure printing is working
    //
}


void test_get_substr(TestObjs *objs) {
    //TODO: implement
    //pre/sufix, try accessing out of bounds in memory
    //str  abc from word dcabc starting at b 

}




