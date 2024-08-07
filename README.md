# Language Speed Test

A series of tests I wanted to write to test the speed of a few languages.

Languages included:
* C++ (Using g++ 13 and clang++ 18)
* Go
* Rust
* Zig
* Java (using openJDK 21)
* Swift
* Python3 (3.10, 3.11, 3.12)
	* This probably won't compare to the other languages
	* Python is included predominantly becaue I wanted to compare the
	speed improvements of recent releases
	* I'm also taking into account the interpreter cost of using 
	various good practices (type hints, `if __name__ == "__main__"`)
* Lua 5 (5.1, 5.2, 5.3, 5.4)
    * As above, this likely doesn't compare to the compiled languages. 
    I want to compare it to python

## To run
* `./test.sh setup` to set up your environment and install the requirements 
	* This is predominantly the various language compilers/interpreters
* `./test.sh synthetic` to run the synthetic test listed below
	* if `SPEEDTEST_ITERS` environment variable isn't set, this
	will fail
* `./test.sh view-syn` to view the output of the synthetic tests in a
	tabular format
* `./test.sh gol` to run the game of life test listed below

### Synthetic Test
1. Read the number of iterations from an environment variable (SPEEDTEST_ITERS)
2. Create an integer array of size 1000 filled completely with 0s
3. Update the first 100 values to be equal to their index
4. Pop the first 10 off and append them to the end

The results are written in csv format to `out/synthetic_results.csv`

### gol test
This runs game of life starting with the gospel glider gun and
iterating 100,000 times
