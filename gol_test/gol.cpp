#include <iostream>
#include <array>
#include <cassert>

int main() {
    // Construct 50x50 board
    std::array<std::array<bool, 50>, 50> board = {};

    // Populate certain cells 
    std::array<std::pair<int, int>, 36> glider_gun = {{
        {1, 5}, {1, 6}, {2, 5}, {2, 6}, {11, 5}, {11, 6}, {11, 7}, {12, 4}, {12, 8}, {13, 3}, {13, 9}, {14, 3}, {14, 9},
        {15, 6}, {16, 4}, {16, 8}, {17, 5}, {17, 6}, {17, 7}, {18, 6}, {21, 3}, {21, 4}, {21, 5}, {22, 3}, {22, 4}, {22, 5},
        {23, 2}, {23, 6}, {25, 1}, {25, 2}, {25, 6}, {25, 7}, {35, 3}, {35, 4}, {36, 3}, {36, 4}
    }};

    for (const auto& cell : glider_gun) {
        board[cell.first][cell.second] = true;
    }

    std::array<std::pair<int, int>, 8> relatives = {{
        {-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}
    }};
    
    // For 100,000 iterations
    for (int i = 0; i < 100000; ++i) {
        std::array<std::array<bool, 50>, 50> new_board = {};

        for (size_t idx = 0; idx < board.size(); ++idx) {
            for (size_t idy = 0; idy < board[idx].size(); ++idy) {
                int live_neighbors = 0;

                for (const auto& rel : relatives) {
                    int new_i = static_cast<int>(idx) + rel.first;
                    int new_j = static_cast<int>(idy) + rel.second;
                    if (new_i >= 0 && new_i < 50 && new_j >= 0 && new_j < 50) {
                        if (board[new_i][new_j]) {
                            ++live_neighbors;
                        }
                    }
                }

                if (board[idx][idy]) {
                    new_board[idx][idy] = (live_neighbors == 2 || live_neighbors == 3);
                } else {
                    new_board[idx][idy] = (live_neighbors == 3);
                }
            }
        }

        board = new_board;
    }

    std::array<std::pair<int, int>, 63> filled_cells = {{
        {1, 5}, {1, 6}, {2, 5}, {2, 6}, {7, 5}, {7, 6}, {7, 7}, {8, 5}, {8, 6}, {8, 7},
        {9, 4}, {9, 8}, {11, 3}, {11, 4}, {11, 8}, {11, 9}, {16, 3}, {16, 4}, {16, 5},
        {17, 7}, {17, 8}, {18, 7}, {18, 8}, {19, 8}, {19, 9}, {20, 6}, {20, 8}, 
        {21, 6}, {21, 7}, {24, 1}, {24, 2}, {24, 6}, {24, 7}, {25, 1}, {25, 2}, 
        {25, 6}, {25, 7}, {26, 13}, {27, 3}, {27, 4}, {27, 5}, {27, 14}, {27, 15}, 
        {28, 3}, {28, 4}, {28, 5}, {28, 13}, {28, 14}, {29, 4}, {34, 20}, 
        {34, 22}, {35, 3}, {35, 4}, {35, 21}, {35, 22}, {36, 3}, {36, 4},
        {36, 21}, {41, 28}, {42, 29}, {42, 30}, {43, 28}, {43, 29}
    }};

    for (const auto& cell : filled_cells) {
        if (board[cell.first][cell.second] != true) {
            std::cerr << "Assertion failed at cell: (" << cell.first << ", " << cell.second << ")\n";
            return 1;
        }
    }

    return 0;
}
