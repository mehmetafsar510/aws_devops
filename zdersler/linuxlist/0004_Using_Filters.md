# https://youtu.be/RynYYIrFlJ8  complementary video from LMS

# Pipes '|' send the output of one command as input of another command.

tac                                  # output text reverse order

|                                    # we can write another command on first output

tee                                  # we can copy first output with tee command to anouther file

cut                                  # The cut filter can select columns from files, depending on a delimiter or a count of bytes

cut -d: -f1-3 /etc/passwd | tail -3  # d means delimiter 
                                     # f means field

tr                                   # It is used for translating and deleting characters.

cat clarusway.txt | tr -d e          # delete all "e" char in the text

cat clarusway.txt | tr [a-z] [A-Z]   # change all lower char to upper char

cat clarusway.txt | tr [A-Z] [a-z]   # change all upper char to lower char

wc                                   # counting words, lines and char is easy with wc command

wc -l tennis.txt                     # count lines in tennis.txt

wc -w tennis.txt                     # count words in tennis.txt

wc -c tennis.txt                     # count chars in tennis.txt

# sort                               # The sort filter will default to an alphabetical sort.

sort -r	                             # the flag returns the results in reverse order
sort -f	                             # the flag does case insensitive sorting
sort -n	                             # the flag returns the results as per numerical order

# uniq                               # With uniq you can remove duplicates from a sorted list.

sort list.txt 
sort list.txt | uniq

# comm                               # Comparing streams (or files) can be done with the comm. By default, comm will output three columns.

comm list1.txt list2.txt             # col 1 lines unique to list1, col2 lines unique to list2, col3 lines that appear in both files

# https://youtu.be/RynYYIrFlJ8 complementary video about filters
