const std = @import("std");
const util = @import("util.zig");
const day12022 = @import("2022/day1.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const inp = try util.getInput(allocator, 2022, 1);
    defer allocator.free(inp);

    const ans = try day12022.solve(inp);
    std.debug.print("{any}\n", .{ans});
}

// test "simple test" {
//     var list = std.ArrayList(i32).init(std.testing.allocator);
//     defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
//     try list.append(42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
// }
