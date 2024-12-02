const std = @import("std");

pub fn solve(allocator: std.mem.Allocator, inp: []const u8) !struct { part1: i64, part2: i64 } {
    _ = allocator;
    std.debug.print("{s}\n", .{inp});
    return .{ .part1 = 0, .part2 = 0 };
}
