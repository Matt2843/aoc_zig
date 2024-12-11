const std = @import("std");

fn blink(times: usize, stone: usize, dp: *std.AutoHashMap([2]usize, usize)) !usize {
    const key = [2]usize{ times, stone };
    if (dp.get(key)) |cached| {
        return cached;
    }
    if (times == 0) {
        try dp.put(key, 1);
        return 1;
    }
    if (stone == 0) {
        const result = try blink(times - 1, 1, dp);
        try dp.put(key, result);
        return result;
    }

    var buf = [_]u8{0} ** 100;
    const str = try std.fmt.bufPrint(&buf, "{d}", .{stone});
    var result: usize = 0;
    if (str.len % 2 == 0) {
        const left = try std.fmt.parseInt(usize, str[0 .. str.len / 2], 10);
        const right = try std.fmt.parseInt(usize, str[str.len / 2 ..], 10);
        result = try blink(times - 1, left, dp) + try blink(times - 1, right, dp);
    } else {
        result = try blink(times - 1, stone * 2024, dp);
    }
    try dp.put(key, result);
    return result;
}

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { part1: usize, part2: usize } {
    const input_trimmed = std.mem.trim(u8, input, " \r\n");

    var part1: usize = 0;
    var part2: usize = 0;
    var dp = std.AutoHashMap([2]usize, usize).init(allocator);
    defer dp.deinit();
    var it = std.mem.splitScalar(u8, input_trimmed, ' ');
    while (it.next()) |stone| {
        const d_stone = try std.fmt.parseInt(usize, stone, 10);
        part1 += try blink(25, d_stone, &dp);
        part2 += try blink(75, d_stone, &dp);
    }
    return .{
        .part1 = part1,
        .part2 = part2,
    };
}
