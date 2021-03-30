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

from mrjob.step import MRStep
from mrjob.job import MRJob
import operator

class MRAvgRatings(MRJob):       
    def configure_args(self):           
        super(MRAvgRatings, self).configure_args()  
        self.add_file_arg('--movies')

    def steps(self):
        return [
            MRStep(mapper=self.mapper_get_ratings,
                    reducer_init=self.reducer_init,
                    reducer=self.reducer_count_ratings)
        ]

    def mapper_get_ratings(self, key, line):
        (userID, movieID, rating, timestamp) = line.split(',')
        yield movieID, float(rating)

    def reducer_init(self):
        self.movieNames = {}
        with open(str(self.options.movies)) as f:
            for line in f:
                fields = line.split(',')                
                self.movieNames[fields[0]] = fields[1]

    def reducer_count_ratings(self, movieID, ratings):        
        total = 0
        count = 0
        for rating in ratings:
            total += rating
            count += 1
            
        yield self.movieNames[movieID], total / count

if __name__ == '__main__':
    MRAvgRatings.run()
