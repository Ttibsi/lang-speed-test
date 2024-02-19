#include <format>
#include <fstream>
#include <iostream>
#include <string>
#include <stringstream>
#include <unordered_map>
#include <vector>

// https://godbolt.org/z/nvq36jc7d
// Note that this is incomplete

int main() {
	std::ifstream ifs("shakespeare_test/text.txt");
	std::string txt_line;
	std::vector<std::string> lines;

	while (std::getline(ifs, txt_line)) { lines.push_back(txt_line); }

	std::unordered_map<int, int> length_counter;
	std::unordered_map<std::string, int> word_counter;
	int num_of_words = 0;

	for (auto&& line: lines) {
		std::stringstream ss(line);
		std::string word;

		while(ss >> word) {
			if (!(length_counter.contains(word.size()))) {
				length_counter.insert({word.size(), 0})
			}
			length_counter[word.size()]++;

			if (word.size() >= 3) {
				if (!(word_counter.contains(word))) {
					word_counter.insert({word, 0})
				}
				word_counter[word]++;
			}

			num_of_words++;
		}
	}

	std::cout << "length_counter: {";
	for (auto&& pair: length_counter) { std::cout << pair.first << ": " << pair.second; }
	std::cout << "}";

	float avg_length = 0.0;
	for (auto&& pair: length_counter) { avg_length += pair.first * pair.second; }
	avg_length /= num_of_words;

	std::cout << "\naverage length: " << std::format("{%.2f}", avg_length);

}
