
def main() -> None:
    # Construct 50x50 board
    board: list[list[bool]] = []
    for x in range(50):
        board.append([0] * 50)

    # populate certain cells 
    glider_gun: list[tuple[int, int]] = [
        (1, 5), (1, 6), (2, 5), (2, 6), (11, 5), (11, 6), (11, 7), (12, 4), (12, 8), (13, 3), (13, 9), (14, 3), (14, 9),
        (15, 6), (16, 4), (16, 8), (17, 5), (17, 6), (17, 7), (18, 6), (21, 3), (21, 4), (21, 5), (22, 3), (22, 4), (22, 5),
        (23, 2), (23, 6), (25, 1), (25, 2), (25, 6), (25, 7), (35, 3), (35, 4), (36, 3), (36, 4)
    ]

    for cell in glider_gun:
        board[cell[0]][cell[1]] = True

    relatives: list[tuple[int, int]] = [
        (-1, -1),
        (-1, 0),
        (-1, 1),
        (0, -1),
        (0, +1),
        (+1, -1),
        (+1, 0),
        (+1, +1),
    ]
    
    # for 100,000 iterations, 
    for i in range(100000):
        new_board: list[list[bool]] = []
        for x in range(50):
            new_board.append([0] * 50)
    
        for idx, row in enumerate(board):
            for idy, cell in enumerate(row):
                # check each neighbor
                live_neighbors = 0
    
                for rel in relatives:
                    try:
                        if board[idx + rel[0]][idy + rel[1]]:
                            live_neighbors += 1
                    except IndexError:
                        continue
    
                # Any live cell with fewer than two live neighbors dies, as if by underpopulation.
                # Any live cell with two or three live neighbors lives on to the next generation.
                # Any live cell with more than three live neighbors dies, as if by overpopulation.
                # Any dead cell with exactly three live neighbors becomes a live cell, as if by reproduction.
    
                if cell:
                    if live_neighbors == 2 or live_neighbors == 3:
                        new_board[idx][idy] = True
                    else:
                        new_board[idx][idy] = False
                else:
                    new_board[idx][idy] = int(live_neighbors == 3)
    
        board = new_board

    filled_cells = [
        (1, 5), (1, 6), (2, 5), (2, 6), (7, 5), (7, 6), (7, 7), (8, 5), (8, 6), (8, 7),
        (9, 4), (9, 8), (11, 3), (11, 4), (11, 8), (11, 9), (16, 3), (16, 4), (16, 5),
        (17, 7), (17, 8), (18, 7), (18, 8), (19, 8), (19, 9), (20, 6), (20, 8), 
        (21, 6), (21, 7), (24, 1), (24, 2), (24, 6), (24, 7), (25, 1), (25, 2), 
        (25, 6), (25, 7), (26, 13), (27, 3), (27, 4), (27, 5), (27, 14), (27, 15), 
        (28, 3), (28, 4), (28, 5), (28, 13), (28, 14), (29, 4), (34, 20), 
        (34, 22), (35, 3), (35, 4), (35, 21), (35, 22), (36, 3), (36, 4),
        (36, 21), (41, 28), (42, 29), (42, 30), (43, 28), (43, 29)
    ]

    for cell in filled_cells:
        assert board[cell[0]][cell[1]] == 1


if __name__ == "__main__":
    raise SystemExit(main())
