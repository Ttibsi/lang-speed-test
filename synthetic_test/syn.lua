local os = require("os")

local iters = tonumber(os.getenv("SPEEDTEST_ITERS"))
for _ = 1, iters do
    local a = {}
    for j = 1, 1000 do
        a[j] = 0
    end

    for j = 1, 100 do
        a[j] = j - 1
    end

    for j = 1, 10 do
        local tmp = a[j]
        a[j] = a[1000 - (10 - j)]
        a[1000 - (10 - j)] = tmp
    end
end
