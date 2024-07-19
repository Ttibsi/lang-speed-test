const std = @import("std");

pub fn main() !void {
    var board: [50][50]bool = undefined;
    const glider_gun = [36]struct { i32, i32 }{
        .{ 1, 5 },  .{ 1, 6 },  .{ 2, 5 },  .{ 2, 6 },  .{ 11, 5 }, .{ 11, 6 },
        .{ 11, 7 }, .{ 12, 4 }, .{ 12, 8 }, .{ 13, 3 }, .{ 13, 9 }, .{ 14, 3 },
        .{ 14, 9 }, .{ 15, 6 }, .{ 16, 4 }, .{ 16, 8 }, .{ 17, 5 }, .{ 17, 6 },
        .{ 17, 7 }, .{ 18, 6 }, .{ 21, 3 }, .{ 21, 4 }, .{ 21, 5 }, .{ 22, 3 },
        .{ 22, 4 }, .{ 22, 5 }, .{ 23, 2 }, .{ 23, 6 }, .{ 25, 1 }, .{ 25, 2 },
        .{ 25, 6 }, .{ 25, 7 }, .{ 35, 3 }, .{ 35, 4 }, .{ 36, 3 }, .{ 36, 4 },
    };
    const relatives = [8]struct { i32, i32 }{
        .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 }, .{ 0, -1 },
        .{ 0, 1 },   .{ 1, -1 }, .{ 1, 0 },  .{ 1, 1 },
    };

    for (glider_gun) |cell| {
        board[@intCast(cell.@"0")][@intCast(cell.@"1")] = true;
    }

    for (0..100000) |_| {
        var new_board: [50][50]bool = undefined;

        for (0..50) |idx| {
            for (0..50) |idy| {
                var live_neighbors: i32 = 0;

                for (relatives) |rel| {
                    const check_x: i32 = @as(i32, @intCast(idx)) + rel.@"0";
                    const check_y: i32 = @as(i32, @intCast(idy)) + rel.@"1";

                    if (check_x < 50 and check_y < 50 and check_x >= 0 and check_y >= 0) {
                        if (board[@intCast(check_x)][@intCast(check_y)]) {
                            live_neighbors += 1;
                        }
                    }
                }

                if (board[idx][idy]) {
                    new_board[idx][idy] = if (live_neighbors == 2 or live_neighbors == 3) true else false;
                } else {
                    new_board[idx][idy] = if (live_neighbors == 3) true else false;
                }
            }
        }

        board = new_board;
    }

    const filled_cells = [63]struct { i32, i32 }{
        .{ 1, 5 },   .{ 1, 6 },   .{ 2, 5 },   .{ 2, 6 },   .{ 7, 5 },   .{ 7, 6 },
        .{ 7, 7 },   .{ 8, 5 },   .{ 8, 6 },   .{ 8, 7 },   .{ 9, 4 },   .{ 9, 8 },
        .{ 11, 3 },  .{ 11, 4 },  .{ 11, 8 },  .{ 11, 9 },  .{ 16, 3 },  .{ 16, 4 },
        .{ 16, 5 },  .{ 17, 7 },  .{ 17, 8 },  .{ 18, 7 },  .{ 18, 8 },  .{ 19, 8 },
        .{ 19, 9 },  .{ 20, 6 },  .{ 20, 8 },  .{ 21, 6 },  .{ 21, 7 },  .{ 24, 1 },
        .{ 24, 2 },  .{ 24, 6 },  .{ 24, 7 },  .{ 25, 1 },  .{ 25, 2 },  .{ 25, 6 },
        .{ 25, 7 },  .{ 26, 13 }, .{ 27, 3 },  .{ 27, 4 },  .{ 27, 5 },  .{ 27, 14 },
        .{ 27, 15 }, .{ 28, 3 },  .{ 28, 4 },  .{ 28, 5 },  .{ 28, 13 }, .{ 28, 14 },
        .{ 29, 4 },  .{ 34, 20 }, .{ 34, 22 }, .{ 35, 3 },  .{ 35, 4 },  .{ 35, 21 },
        .{ 35, 22 }, .{ 36, 3 },  .{ 36, 4 },  .{ 36, 21 }, .{ 41, 28 }, .{ 42, 29 },
        .{ 42, 30 }, .{ 43, 28 }, .{ 43, 29 },
    };

    for (filled_cells) |cell| {
        std.debug.assert(board[@intCast(cell.@"0")][@intCast(cell.@"1")] == true);
    }
}
