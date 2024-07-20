typealias position = (vert: Int, hor: Int)

var board = Array(repeating: Array(repeating: false, count: 50), count: 50)
let glider_gun: [position] = [
    (1, 5), (1, 6), (2, 5), (2, 6), (11, 5), (11, 6), (11, 7), (12, 4), (12, 8), (13, 3),
    (13, 9), (14, 3), (14, 9), (15, 6), (16, 4), (16, 8), (17, 5), (17, 6), (17, 7), (18, 6),
    (21, 3), (21, 4), (21, 5), (22, 3), (22, 4), (22, 5), (23, 2), (23, 6), (25, 1), (25, 2),
    (25, 6), (25, 7), (35, 3), (35, 4), (36, 3), (36, 4),
]

for cell in glider_gun {
    board[cell.vert][cell.hor] = true
}

let relatives: [position] = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]

// 100,000 iterations
for _ in 1...100000 {
    var new_board = Array(repeating: Array(repeating: false, count: 50), count: 50)
    for (idx, row) in board.enumerated() {
        for (idy, cell) in row.enumerated() {
            // check each neighbor
            var live_neighbors = 0

            for rel in relatives {
                let check_x = idx + rel.vert
                let check_y = idy + rel.hor

                if check_x < 0 || check_x >= 50 { continue }
                if check_y < 0 || check_y >= 50 { continue }
                if case board[check_x][check_y] = true {
                    live_neighbors += 1
                }
            }

            // Any live cell with fewer than two live neighbors dies, as if by underpopulation.
            // Any live cell with two or three live neighbors lives on to the next generation.
            // Any live cell with more than three live neighbors dies, as if by overpopulation.
            // Any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction.

            if cell {
                if live_neighbors == 2 || live_neighbors == 3 {
                    new_board[idx][idy] = true
                } else {
                    new_board[idx][idy] = false
                }
            } else {
                new_board[idx][idy] = (live_neighbors == 3)
            }
        }
    }

    board = new_board
}

let filled_cells: [position] = [
    (1, 5), (1, 6), (2, 5), (2, 6), (7, 5), (7, 6), (7, 7), (8, 5), (8, 6), (8, 7),
    (9, 4), (9, 8), (11, 3), (11, 4), (11, 8), (11, 9), (16, 3), (16, 4), (16, 5),
    (17, 7), (17, 8), (18, 7), (18, 8), (19, 8), (19, 9), (20, 6), (20, 8),
    (21, 6), (21, 7), (24, 1), (24, 2), (24, 6), (24, 7), (25, 1), (25, 2),
    (25, 6), (25, 7), (26, 13), (27, 3), (27, 4), (27, 5), (27, 14), (27, 15),
    (28, 3), (28, 4), (28, 5), (28, 13), (28, 14), (29, 4), (34, 20),
    (34, 22), (35, 3), (35, 4), (35, 21), (35, 22), (36, 3), (36, 4),
    (36, 21), (41, 28), (42, 29), (42, 30), (43, 28), (43, 29),
]

for cell in filled_cells { assert(board[cell.vert][cell.hor] == true) }
