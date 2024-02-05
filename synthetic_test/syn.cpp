#include <algorithm>
#include <array>
#include <cstdlib>
#include <string>

int main() {
	int iters = std::stoi(std::getenv("SPEEDTEST_ITERS"));
	for (int i = 0; i < iters; i++) {
		std::array<int, 1000> a = {};
		for (int j = 0; j < 100; j++) a[j] = j;
		for (int j = 0; j < 10; j++) std::swap(a[j], a[1000-(10-j)]);
	}
}
