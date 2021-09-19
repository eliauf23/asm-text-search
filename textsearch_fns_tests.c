#include <stdio.h>
#include <stdlib.h>
#include <string.h> // these functions may be used in the test program
#include "textsearch_fns.h"
#include "tctest.h"

typedef struct {
    const char *pandp;
} TestObjs;


TestObjs *setup(void);
void cleanup(TestObjs *objs);

// TODO: declare test functions

// Example:
// void test_read_line(TestObjs *objs);


int main(int argc, char **argv) {
    // Allow the name of the test function to execute to be specified
    // on the command line
    if (argc > 1) {
        tctest_testname_to_execute = argv[1];
    }

    TEST_INIT();

    // TODO: invoke test functions
    // TEST(test_read_line);

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
    //511 a's followed by 1 b
    objs->maxline = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab";
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
}

// TODO: implementations of other test functions

void test_print_line(TestObjs *objs) {
    //TODO: implement
}

void test_count_occurrences(TestObjs *objs) {
    //TODO: implement
}


void test_find_string_length(TestObjs *objs) {
    //TODO: implement
}



void test_starts_with(TestObjs *objs) {
    //TODO: implement
}


void test_strings_equal(TestObjs *objs) {
    //TODO: implement
}

void test_find_all_occurrences(TestObjs *objs) {
    //TODO: implement
}


void test_get_substr(TestObjs *objs) {
    //TODO: implement
}




