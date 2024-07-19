-- Construct 50x50 board
local board = {}
for i = 1, 50 do
    board[i] = {}
    for j = 1, 50 do
        board[i][j] = false
    end
end

-- Populate certain cells
local glider_gun = {
    {1, 5}, {1, 6}, {2, 5}, {2, 6}, {11, 5}, {11, 6}, {11, 7}, {12, 4}, {12, 8}, {13, 3}, {13, 9}, {14, 3}, {14, 9},
    {15, 6}, {16, 4}, {16, 8}, {17, 5}, {17, 6}, {17, 7}, {18, 6}, {21, 3}, {21, 4}, {21, 5}, {22, 3}, {22, 4}, {22, 5},
    {23, 2}, {23, 6}, {25, 1}, {25, 2}, {25, 6}, {25, 7}, {35, 3}, {35, 4}, {36, 3}, {36, 4}
}

for _, cell in ipairs(glider_gun) do
    board[cell[1]][cell[2]] = true
end

local relatives = {
    {-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}
}

-- For 100,000 iterations
for _ = 1, 100000 do
    local new_board = {}
    for i = 1, 50 do
        new_board[i] = {}
        for j = 1, 50 do
            new_board[i][j] = false
        end
    end

    for idx = 1, 50 do
        for idy = 1, 50 do
            local live_neighbors = 0

            for _, rel in ipairs(relatives) do
                local new_i = idx + rel[1]
                local new_j = idy + rel[2]
                if new_i >= 1 and new_i <= 50 and new_j >= 1 and new_j <= 50 then
                    if board[new_i][new_j] then
                        live_neighbors = live_neighbors + 1
                    end
                end
            end

            if board[idx][idy] then
                new_board[idx][idy] = (live_neighbors == 2 or live_neighbors == 3)
            else
                new_board[idx][idy] = (live_neighbors == 3)
            end
        end
    end

    board = new_board
end

local filled_cells = {
    {1, 5}, {1, 6}, {2, 5}, {2, 6}, {7, 5}, {7, 6}, {7, 7}, {8, 5}, {8, 6}, {8, 7},
    {9, 4}, {9, 8}, {11, 3}, {11, 4}, {11, 8}, {11, 9}, {16, 3}, {16, 4}, {16, 5},
    {17, 7}, {17, 8}, {18, 7}, {18, 8}, {19, 8}, {19, 9}, {20, 6}, {20, 8}, 
    {21, 6}, {21, 7}, {24, 1}, {24, 2}, {24, 6}, {24, 7}, {25, 1}, {25, 2}, 
    {25, 6}, {25, 7}, {26, 13}, {27, 3}, {27, 4}, {27, 5}, {27, 14}, {27, 15}, 
    {28, 3}, {28, 4}, {28, 5}, {28, 13}, {28, 14}, {29, 4}, {34, 20}, 
    {34, 22}, {35, 3}, {35, 4}, {35, 21}, {35, 22}, {36, 3}, {36, 4},
    {36, 21}, {41, 28}, {42, 29}, {42, 30}, {43, 28}, {43, 29}
}

for _, cell in ipairs(filled_cells) do
    if board[cell[1]][cell[2]] ~= true then
        print("Assertion failed at cell: (" .. cell[1] .. ", " .. cell[2] .. ")")
        return 1
    end
end
