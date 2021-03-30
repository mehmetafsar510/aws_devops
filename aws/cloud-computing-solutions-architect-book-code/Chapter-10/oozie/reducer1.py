'''
MIT License

Copyright (c) 2019 Arshdeep Bahga and Vijay Madisetti

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'''

#!/usr/bin/env python 
 from operator import itemgetter 
 import sys 
 current_key = None 
 current_count = 0 
 key = None 
  
 # input comes from STDIN 
 for line in sys.stdin: 
    line = line.strip() 
  
    key, count = line.split('\t', 1) 
    count = int(count) 
  
    if current_key == key: 
        current_count += count 
    else: 
        if current_key: 
            unpackedKey = current_key.split(',') 
            print '%s\t%s' % (current_key, current_count) 
        current_count = count 
            current_key = key 
  
 if current_key == key: 
    unpackedKey = current_key.split(',') 
    print '%s\t%s' % (current_key, current_count)
