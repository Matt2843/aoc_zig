const std = @import("std");

pub fn solve(inp: []const u8) !struct { part1: i64, part2: i64 } {
    var max_calories: i64 = 0;
    var it = std.mem.split(u8, inp, "\n\n");
    while (it.next()) |cal_batch| {
        var local_calories: i64 = 0;
        var it2 = std.mem.split(u8, cal_batch, "\n");
        while (it2.next()) |cal| {
            local_calories += std.fmt.parseInt(i64, cal, 10) catch break;
        }
        if (local_calories > max_calories)
            max_calories = local_calories;
    }
    return .{ .part1 = max_calories, .part2 = -1 };
}
