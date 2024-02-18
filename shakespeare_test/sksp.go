package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"slices"
	"strconv"
	"strings"
)

type kv struct{
	k string 
	v int
}

func fileToLines(fileName string) (lines []string, err error) {
	file, err := os.Open(fileName)
	if err != nil {
		return lines, err
	}
	defer file.Close()
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	return lines, scanner.Err()
}

func topN(m map[string]int, n int) ([]kv, bool) { 
	if len(m) < n {
		return nil, false
	}

	kvs := make([]kv, 0, len(m))
	for k, v := range m {
		kvs = append(kvs, kv{k, v})
	}
	// note the comparison function here:
	// we want the highest VALUES to go first, and then   the minimum KEYS
	slices.SortFunc(kvs, func(a, b kv) int {
		switch {
		case a.v < b.v:
			return 1
		case a.v > b.v:
			return -1
		case a.k < b.k:
			return -1
		case a.k > b.k:
			return 1
		default:
			return 0
		}
	})
	return kvs[:n], true
}


func main() {
	length_counter := make(map[int]int)
	word_counter := make(map[string]int)
	num_of_words := 0

	lines, err := fileToLines("shakespeare_test/text.txt")
	if err != nil { log.Println(err.Error()) }
	
	for _, line := range lines {
		words := strings.Split(line, " ")

		for _, word := range words {
			num_of_words++
			length_counter[len(word)]++

			if len(word) >= 3 {
				word_counter[word]++
			}
		}
	}

	for k, v := range length_counter {
		fmt.Print(strconv.Itoa(k) + ": " + strconv.Itoa(v) + ", ")
	}

	var avg_length float64
	for k, v := range length_counter {
		avg_length += float64(k * v)
	}

	avg_length /= float64(num_of_words)
	fmt.Println("average length: " + fmt.Sprintf("%.02f", avg_length))

	out, ok := topN(word_counter, 3)
	if ok {
		fmt.Print("Most common words: ")
		for _, v := range out {
			fmt.Print(v.k + "(" + strconv.Itoa(v.v) + ") ")
		}
	}
	fmt.Println("")
}
