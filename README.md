# Language Speed Test

A series of tests I wanted to write to test the speed of a few languages. Tests
run on both Arm and x86 machines in github actions using the same Ubuntu 24.04
OS runner.

Languages included:
* C++ (Using g++ 14, clang++ 19, and zig 0.13)
* Go (1.23)
* Rust (1.83)
* Zig 0.13
* Java (using openJDK 23)
* Swift (6.0.3)
* Python3 (3.10, 3.11, 3.12, 3.13)
        * This probably won't compare to the other languages
        * Python is included predominantly becaue I wanted to compare the
        speed improvements of recent releases
        * I'm also taking into account the interpreter cost of using
        various good practices (type hints, `if __name__ == "__main__"`)
* Lua 5 (5.1, 5.2, 5.3, 5.4)
    * As above, this likely doesn't compare to the compiled languages.
    I want to compare it to python

## Manually running the tests locally
The test bash script is included to set up your environment and run the tests
on your own machine. It's recommended that you use a docker container. The
commands in the bash script are designed for an ubuntu-based environment and
will need adjusting if you use something alternative.

* `./test.sh setup` to set up your environment and install languages and
toolchains
* `./test.sh synthetic` to run the synthetic test listed below
        * if `SPEEDTEST_ITERS` environment variable isn't set, this
        will fail
* `./test.sh view-syn` to view the output of the synthetic tests in a
        tabular format
* `./test.sh gol` to run the game of life test listed below

### Synthetic Test
1. Read the number of iterations from an environment variable
(`SPEEDTEST_ITERS`)
2. Create an integer array of size 1000 filled completely with 0s
3. Update the first 100 values to be equal to their index
4. Pop the first 10 off and append them to the end

The results are written in csv format to `out/synthetic_results.csv`

### gol test
This runs game of life starting with the gospel glider gun and
iterating 100,000 times, then comparing the board to the expected layout

## Results
* I'm surprised that the Golang binary sizes are so big -- I was expecting it
to be smaller compared to Rust or Swift. It does however make sense when you
take into consideration that Go is statically linked and the other languages
arent (by default).
* It looks like the biggests speed improvements in python came in the 3.10-3.11
upgrade, as future versions have the same result within a margin of error.
* Meanwhile it appears across the various results that Lua hasn't significanly
sped up across versions. I don't think that we expected this to be the case
    * Potentially in the future I should try adding LuaJIT as well
* It appears that clang vs gcc makes no notable difference on binary size
or simple processing speed for c++ codebases. There are notable things we
could do to affect speed across specific compilers, but I don't think those
would affect these simple tests

