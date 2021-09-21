#include <stdio.h>
#include <stdlib.h>
#include "tctest.h"
#include "textsearch_fns.h"

typedef struct {
    const char *pandp;
    const char *palindromes;
    const char *maxline_513;
    const char *maxline_over;
    const char *maxline_512;
    const char *empty;
    const char *justnewline;
    const char *randomAlphanumeric;
    const char *single_char;
} TestObjs;


TestObjs *setup(void);
void cleanup(TestObjs *objs);

void test_read_line(TestObjs *objs);
void test_print_line(TestObjs *objs);
void test_count_occurrences(TestObjs *objs);
void test_find_string_length(TestObjs *objs);
void test_starts_with();
void test_strings_equal();
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
    objs->maxline_over = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaastar\n";
    //510 chars and \n
    objs->maxline_512 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab\n";
    objs->empty = "";
    objs->justnewline = "\n";

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
       objs->single_char = "z";
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

   //TODO: add more files; 
    
}


void test_print_line(TestObjs *objs) {
    //void print_line(FILE *out, const char *buf) {


   //simple printing test
   char buf_1[MAXLINE + 1];
   FILE *out_1 = fmemopen(buf_1, sizeof(buf_1),"w");
   print_line(out_1, "This is a test line. Did it work??");
   ASSERT(0 == strcmp(buf_1, "This is a test line. Did it work??"));
   fclose(out_1);


    //print line that is greater than the maxline limit
    char buf_2[MAXLINE + 1];
    FILE *out_2 = fmemopen(buf_2, sizeof(buf_2),"w");
    print_line(out_2, objs->maxline_513);
    ASSERT(0 == strcmp(buf_2, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" ));
    fclose(out_2);         


    //doesn't print to null out
    //TODO: Does buf_3 = null or just empty?
    char buf_3[MAXLINE + 1];
    FILE *out_3 = NULL;
    print_line(out_3, objs->palindromes);
    ASSERT(buf_3 == NULL);
    fclose(out_3);


    //pass in PandP
    char buf_4[MAXLINE + 1];

    FILE *out_4 = fmemopen((char *) buf_4, sizeof(buf_4), "w");
    print_line(out_4, objs->pandp);
    ASSERT(0 == strcmp(buf_4, "It is a truth universally acknowledged, that a single man in\n"));
    fclose(out_4);

    //only ever use it for stoud and by defition will never be null
}


void test_count_occurrences(TestObjs *objs) {

    //simple case
    ASSERT(count_occurrences("It is a truth universally acknowledged, that a single man in", "truth") == 1);

    //checking case sensitivity 1
    ASSERT(count_occurrences("possession of a good fortune, must be in want of a wife.", "Good") == 0);

    // just newline char
    ASSERT(count_occurrences("\n", "NA") == 0);

    //ignores punctuation 
    //line reads in text "neighbourhood, this"
    ASSERT(count_occurrences("on his first entering a neighbourhood, this truth is so well", "neighbourhood, this") == 1);

    //testing multiple occurances of substrings
    ASSERT(count_occurrences("fixed in the minds of the surrounding families, that he is", "in") == 3);

    //spacing test
    ASSERT(count_occurrences("considered as the rightful property of some one or other of their", "s o m e") == 0);

    //testing letters after char limit
    ASSERT(count_occurrences(objs->maxline_513, "b") == 0);

    //testing word that overflows over the char limit
    ASSERT(count_occurrences(objs->maxline_over, "star") == 0);

}


void test_find_string_length(TestObjs *objs) {

    // empty string
    ASSERT(find_string_length(objs->empty) == 0);

    //new line
    ASSERT(find_string_length(objs->justnewline) == 1);
    //NOTE: This will never be passed into find_string_length because we check for newlines before calling function

    //one char
    ASSERT(find_string_length(objs->single_char) == 1);

    //maxline_513 len = 513
    //we find the full length and check for >512 in other functions
    ASSERT(find_string_length(objs->maxline_513) == 514);

    //we find the full length and check for >512 in other functions
    ASSERT(find_string_length(objs->maxline_512) == 512);

    //random
    ASSERT(find_string_length(objs->palindromes) == 19);

    //line from pandp
    ASSERT(find_string_length("considered as the rightful property of some one or other of their\n") == 66);

}


void test_starts_with() {

    //simple true check
    ASSERT(starts_with("wordalala", "wor") == 1);

    //simple false check
    ASSERT(starts_with("wordalala", "not") == 0);

    //prefix is longer than string
    ASSERT(starts_with("wor", "wordalala") == 0);

    //words are equal
    ASSERT(starts_with("word", "word") == 1);

    //empty prefix
    ASSERT(starts_with("summer nights", "") == 1);

    //empty word
    ASSERT(starts_with("", "summer") == 0);

    //check with two words
    ASSERT(starts_with("summer nights", "summer") == 1);
    
}


void test_strings_equal() {
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
    ASSERT(strings_equal("yXxwXcxXgkHS7Apt7\n", "yXxwXcxXgkHS7Apt7") == 0);

}


void test_find_all_occurrences(TestObjs *objs) {
    //uses printlnine to print when printOccurances=1
    //SO no need to test printing occurances.


    FILE *in;
    in = fmemopen((char *) objs->pandp, strlen(objs->pandp), "r");
    
    //simple counting 1
    ASSERT(find_all_occurrences(in, "ma", 0) == 3);

    //simple counting 2
    //ASSERT(find_all_occurrences(in, "a", 0) == 17);

    //no occurances
    ASSERT(find_all_occurrences(in, "peanutbutter", 0) == 0);
    
    fclose(in);

    FILE *in_2;
    in_2 = fmemopen((char *) objs->maxline_513, strlen(objs->maxline_513), "r");
    
    //occurance after the maxline
    ASSERT(find_all_occurrences(in_2,"b", 0) == 0);

    fclose(in_2);

    FILE *in_3;
    in_3 = fmemopen((char *) objs->maxline_over, strlen(objs->maxline_over), "r");

    ASSERT(find_all_occurrences(in_3, "star", 0 ) == 0);

    fclose(in_3);
    

}


void test_get_substr(TestObjs *objs) {
    //char *get_substr(const char *line, int str_len, int i)

    //TODO: implement
    // palindromes = "racecaracecar...."
    ASSERT(0 == strcmp(get_substr(objs->palindromes, strlen(objs->palindromes), 3, 0), "rac"));

    //first word
    ASSERT(0 == strcmp(get_substr("hello and welcome to the tets of this program", strlen("hello and welcome to the tets of this program"), 5, 0), "hello"));

    //last word
    ASSERT(0 == strcmp(get_substr("hello and welcome to the tets of this program", strlen("hello and welcome to the tets of this program"), 7, 38), "program"));

    //middle world
    ASSERT(0 == strcmp(get_substr("hello and welcome to the tets of this program", strlen("hello and welcome to the tets of this program"), 3, 21), "the"));

    //DNE
    ASSERT(NULL == get_substr("", 0, 1, 2));

    //i + str_len> line_len BUT i < line_len
    ASSERT(0 == strcmp(get_substr("hello and welcome to the tets of this program", strlen("hello and welcome to the tets of this program"), 3, 43), "am"));

    // i == line_len
    ASSERT(0 == strcmp(get_substr("hello and welcome to the tets of this program", strlen("hello and welcome to the tets of this program"), 4, 45), ""));
    
    //i = line_len + 1
    ASSERT(get_substr("hello and welcome to the tets of this program", strlen("hello and welcome to the tets of this program"),  6, 46) == NULL);
}




