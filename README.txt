Elizabeth Aufzien eaufzie1@jhu.edu
Rose Wolkind rwolkin1@jhu.edu


MS1: Elizabeth took the lead with the functions and Rosie took the lead with unit testing. We worked together on general planning/debugging.

MS2: We worked together to implement and debug the first assembly function.

MS3: We implemented the rest of the functions, implemented the main and debugged our tests from MS1. 

Notes:
-One of the main things we struggled with was the specificatons of what a valid line is. We weren't sure 
    if we were supposed to only read 511 chars and add a null terminator or just 512 characters. 
-In our tests from MS1, we didn't properly check for end of line in our C code and then replicated the issue in our asm code and 
    then didn't properly jump when testing the buffer. 

We implemented read_line, print_line, (and fixed the MS2 versions of) find_string_length, and strings_equal together.

Rosie implemented count_occurrences & find_all_occurrences and Elizabeth debugged it.
Elizabeth implemented the main function and Rosie debugged it.

Our workflow consisted of us planning together and either worked side by side, or worked on various aspects 
of the implementation alone and the other partner would work on debugging. 

