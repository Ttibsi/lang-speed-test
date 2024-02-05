const std = @import("std");

pub fn main() !void {
        const iters_str = std.os.getenv("SPEEDTEST_ITERS");
        var iters: usize = 0;
        if (iters_str) |i| {
                iters = try std.fmt.parseInt(usize, i, 10);
        }

	for (0..iters) |_| {
		var array = [_]usize{0} ** 1000;
		for (0..100) |j| { array[j] = j; }
		for (0..10) |j| {
			const tmp = array[j];
			array[j] = array[1000 - (10 - j)];
			array[1000 - (10 - j)] = tmp;
		}
	}
}
