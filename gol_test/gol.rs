pub fn main() {
    let mut board: [[bool; 50]; 50] = [[false; 50]; 50];
    let glider_gun: [(usize, usize); 36] = [
        (1, 5), (1, 6), (2, 5), (2, 6), (11, 5), (11, 6), (11, 7), (12, 4), 
        (12, 8), (13, 3), (13, 9), (14, 3), (14, 9), (15, 6), (16, 4), (16, 8), 
        (17, 5), (17, 6), (17, 7), (18, 6), (21, 3), (21, 4), (21, 5), (22, 3), 
        (22, 4), (22, 5), (23, 2), (23, 6), (25, 1), (25, 2), (25, 6), (25, 7), 
        (35, 3), (35, 4), (36, 3), (36, 4),
    ];
    let relatives: [(i32, i32); 8] = [
        (-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1),
    ];

    for i in 0..glider_gun.len() {
        let cell = glider_gun[i];
        board[cell.0][cell.1] = true;
    }

    for _ in 0..100000 {
        let mut new_board: [[bool; 50]; 50] = [[false; 50]; 50];

        for idx in 0..50 {
            for idy in 0..50 {
                let mut live_neighbors = 0;

                for j in 0..relatives.len() {
                    let check_x = (idx + relatives[j].0) as usize;
                    let check_y = (idy + relatives[j].1) as usize;

                    if check_x < 50 && check_y < 50 {
                        if board[check_x][check_y] { live_neighbors += 1; }
                    }
                }

                if board[idx as usize][idy as usize] {
                    if live_neighbors == 2 || live_neighbors == 3 {
                        new_board[idx as usize][idy as usize] = true;
                    } else {
                        new_board[idx as usize][idy as usize] = false;
                    }
                } else {
                    if live_neighbors == 3 {
                        new_board[idx as usize][idy as usize] = true;
                    } else {
                        new_board[idx as usize][idy as usize] = false;
                    }
                }
            }
        }

        board = new_board;
    }

    let filled_cells: [(usize, usize); 63] = [
        (1, 5), (1, 6), (2, 5), (2, 6),  (7, 5), (7, 6), (7, 7), (8, 5), 
        (8, 6), (8, 7), (9, 4), (9, 8),  (11, 3), (11, 4), (11, 8), (11, 9), 
        (16, 3), (16, 4), (16, 5), (17, 7),  (17, 8), (18, 7), (18, 8), (19, 8), 
        (19, 9), (20, 6), (20, 8), (21, 6),  (21, 7), (24, 1), (24, 2), (24, 6), 
        (24, 7), (25, 1), (25, 2), (25, 6),  (25, 7), (26, 13), (27, 3), (27, 4), 
        (27, 5), (27, 14), (27, 15), (28, 3),  (28, 4), (28, 5), (28, 13), (28, 14), 
        (29, 4), (34, 20), (34, 22), (35, 3),  (35, 4), (35, 21), (35, 22), (36, 3), 
        (36, 4), (36, 21), (41, 28), (42, 29),  (42, 30), (43, 28), (43, 29)
    ];

    for idx in 0..filled_cells.len() {
        let cell = filled_cells[idx];
        assert!(board[cell.0][cell.1] == true);
    }
}
