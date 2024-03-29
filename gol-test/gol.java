import java.awt.*;

class Gol {
	public static void main(String[] args) {
        boolean[][] board = new boolean[50][50];
        Point[] gliderGun = new Point[]{
            new Point(1, 5), new Point(1, 6), new Point(2, 5), new Point(2, 6), 
            new Point(11, 5), new Point(11, 6), new Point(11, 7), new Point(12, 4), 
            new Point(12, 8), new Point(13, 3), new Point(13, 9), new Point(14, 3), 
            new Point(14, 9), new Point(15, 6), new Point(16, 4), new Point(16, 8), 
            new Point(17, 5), new Point(17, 6), new Point(17, 7), new Point(18, 6), 
            new Point(21, 3), new Point(21, 4), new Point(21, 5), new Point(22, 3), 
            new Point(22, 4), new Point(22, 5), new Point(23, 2), new Point(23, 6), 
            new Point(25, 1), new Point(25, 2), new Point(25, 6), new Point(25, 7), 
            new Point(35, 3), new Point(35, 4), new Point(36, 3), new Point(36, 4)
        };
        Point[] relatives = new Point[]{
            new Point(-1, -1), new Point(-1, 0), new Point(-1, 1), new Point(0, -1),
            new Point(0, +1), new Point(+1, -1), new Point(+1, 0), new Point(+1, +1),
        };

        for (Point cell: gliderGun) {
            board[cell.x][cell.y] = true;
        }

        // TODO: 100000
        for (int i = 0; i < 10; i++) {
            boolean[][] new_board = new boolean[50][50];

            for (int idx = 0; idx < 50; idx++) {
                for (int idy = 0; idy < 50; idy++) {
                    int live_neighbors = 0;

                    for (Point rel: relatives) {
                        try {
                            if (board[idx + rel.x][idy + rel.y]) live_neighbors++;
                        } catch (IndexOutOfBoundsException e) {
                            continue;
                        }
                    }

                    if (board[idx][idy]) {
                        new_board[idx][idy] = (live_neighbors == 2 || live_neighbors == 3) ? true : false;
                    } else {
                        new_board[idx][idy] = (live_neighbors == 3) ? true : false;
                    }
                }
            }

            board = new_board;
        }

        Point[] filledCells = new Point[]{
            new Point(1, 5), new Point(1, 6), new Point(2, 5), new Point(2, 6), 
            new Point(7, 5), new Point(7, 6), new Point(7, 7), new Point(8, 5), 
            new Point(8, 6), new Point(8, 7), new Point(9, 4), new Point(9, 8), 
            new Point(11, 3), new Point(11, 4), new Point(11, 8), new Point(11, 9), 
            new Point(16, 3), new Point(16, 4), new Point(16, 5), new Point(17, 7), 
            new Point(17, 8), new Point(18, 7), new Point(18, 8), new Point(19, 8), 
            new Point(19, 9), new Point(20, 6), new Point(20, 8), new Point(21, 6), 
            new Point(21, 7), new Point(24, 1), new Point(24, 2), new Point(24, 6), 
            new Point(24, 7), new Point(25, 1), new Point(25, 2), new Point(25, 6), 
            new Point(25, 7), new Point(26, 13), new Point(27, 3), new Point(27, 4), 
            new Point(27, 5), new Point(27, 14), new Point(27, 15), new Point(28, 3), 
            new Point(28, 4), new Point(28, 5), new Point(28, 13), new Point(28, 14), 
            new Point(29, 4), new Point(34, 20), new Point(34, 22), new Point(35, 3), 
            new Point(35, 4), new Point(35, 21), new Point(35, 22), new Point(36, 3), 
            new Point(36, 4), new Point(36, 21), new Point(41, 28), new Point(42, 29), 
            new Point(42, 30), new Point(43, 28), new Point(43, 29)
        };

        for (Point cell: filledCells) {
            assert board[cell.x][cell.y] == true;
        }
    }
}
