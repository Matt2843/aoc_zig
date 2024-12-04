const std = @import("std");

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { part1: i64, part2: i64 } {
    _ = allocator;
    std.debug.print("{s}\n", .{input});
    return .{
        .part1 = 0,
        .part2 = 0,
    };
}
