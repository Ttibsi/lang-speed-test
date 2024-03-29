#include <array>
#include <cassert>
#include <stdexcept>
#include <tuple>

int main() {
    std::array<std::array<bool, 50>, 50> board;
    std::array<std::pair<int, int>, 36> glider_gun = {
        std::pair{1, 5}, std::pair{1, 6}, std::pair{2, 5}, std::pair{2, 6}, 
        std::pair{11, 5}, std::pair{11, 6}, std::pair{11, 7}, std::pair{12, 4}, 
        std::pair{12, 8}, std::pair{13, 3}, std::pair{13, 9}, std::pair{14, 3}, 
        std::pair{14, 9}, std::pair{15, 6}, std::pair{16, 4}, std::pair{16, 8}, 
        std::pair{17, 5}, std::pair{17, 6}, std::pair{17, 7}, std::pair{18, 6}, 
        std::pair{21, 3}, std::pair{21, 4}, std::pair{21, 5}, std::pair{22, 3}, 
        std::pair{22, 4}, std::pair{22, 5}, std::pair{23, 2}, std::pair{23, 6}, 
        std::pair{25, 1}, std::pair{25, 2}, std::pair{25, 6}, std::pair{25, 7}, 
        std::pair{35, 3}, std::pair{35, 4}, std::pair{36, 3}, std::pair{36, 4}
    };
    std::array<std::pair<int, int>, 8> relatives = {
        std::pair{-1, -1}, std::pair{-1, 0}, std::pair{-1, 1}, std::pair{0, -1},
        std::pair{0, +1}, std::pair{+1, -1}, std::pair{+1, 0}, std::pair{+1, +1},
    };

    for (int i = 0; i < 100000; i++) {
        std::array<std::array<bool, 50>, 50> new_board;

        for (int idx = 0; idx < 50; idx++) {
            for (int idy = 0; idy < 50; idy++) {
                int live_neighbors = 0;

                for (auto&& rel: relatives) {
                    try {
                        if (board[idx + rel.first][idy + rel.second]) live_neighbors++;
                    } catch (const std::out_of_range& e) {
                        continue;
                    }
                }

                if (board[idx][idy]) {
                    new_board[idx][idy] = (live_neighbors == 2 || live_neighbors == 3) ? 1 : 0;
                } else {
                    new_board[idx][idy] = (live_neighbors == 3) ? 1 : 0;
                }
            }
        }

         board = new_board;
    }

    std::array<std::pair<int, int>, 63> filled_cells = {
        std::pair{1, 5}, std::pair{1, 6}, std::pair{2, 5}, std::pair{2, 6}, 
        std::pair{7, 5}, std::pair{7, 6}, std::pair{7, 7}, std::pair{8, 5}, 
        std::pair{8, 6}, std::pair{8, 7}, std::pair{9, 4}, std::pair{9, 8}, 
        std::pair{11, 3}, std::pair{11, 4}, std::pair{11, 8}, std::pair{11, 9}, 
        std::pair{16, 3}, std::pair{16, 4}, std::pair{16, 5}, std::pair{17, 7}, 
        std::pair{17, 8}, std::pair{18, 7}, std::pair{18, 8}, std::pair{19, 8}, 
        std::pair{19, 9}, std::pair{20, 6}, std::pair{20, 8}, std::pair{21, 6}, 
        std::pair{21, 7}, std::pair{24, 1}, std::pair{24, 2}, std::pair{24, 6}, 
        std::pair{24, 7}, std::pair{25, 1}, std::pair{25, 2}, std::pair{25, 6}, 
        std::pair{25, 7}, std::pair{26, 13}, std::pair{27, 3}, std::pair{27, 4}, 
        std::pair{27, 5}, std::pair{27, 14}, std::pair{27, 15}, std::pair{28, 3}, 
        std::pair{28, 4}, std::pair{28, 5}, std::pair{28, 13}, std::pair{28, 14}, 
        std::pair{29, 4}, std::pair{34, 20}, std::pair{34, 22}, std::pair{35, 3}, 
        std::pair{35, 4}, std::pair{35, 21}, std::pair{35, 22}, std::pair{36, 3}, 
        std::pair{36, 4}, std::pair{36, 21}, std::pair{41, 28}, std::pair{42, 29}, 
        std::pair{42, 30}, std::pair{43, 28}, std::pair{43, 29}
    };

    for (auto&& cell: filled_cells) { assert(board[cell.first][cell.second] == 1); }


    return 0;
}
