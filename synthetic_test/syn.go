package main

import (
	"os"
	"strconv"
)

func main() {
	iters_str := os.Getenv("SPEEDTEST_ITERS")
	iters, _ := strconv.Atoi(iters_str)

	for i := 0; i < iters; i++ {
		var array [1000]int

		for j := 0; j < 100; j++ { array[j] = j }

		for j := 0; j < 10; j++ {
			tmp := array[j]
			array[j] = array[1000 - (10 - j)]
			array[1000 - (10 - j)] = tmp
		}
	}
}
