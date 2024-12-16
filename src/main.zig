const std = @import("std");
const util = @import("util.zig");
const day = @import("2024/day10.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const inp = try util.getInput(allocator, 2024, 10);
    defer allocator.free(inp);

    const ans = try day.solve(allocator, inp);
    std.debug.print("{any}\n", .{ans});
}
