const std = @import("std");

pub fn solve(allocator: std.mem.Allocator, inp: []const u8) !struct { part1: i64, part2: i64 } {
    var lar = std.ArrayList(i64).init(allocator);
    defer lar.deinit();
    var rar = std.ArrayList(i64).init(allocator);
    defer rar.deinit();

    var lit = std.mem.splitScalar(u8, inp, '\n');
    while (lit.next()) |line| {
        if (line.len == 0)
            break;
        var nit = std.mem.splitSequence(u8, line, "   ");
        try lar.append(try std.fmt.parseInt(i64, nit.next().?, 10));
        try rar.append(try std.fmt.parseInt(i64, nit.next().?, 10));
    }

    std.mem.sort(i64, lar.items, {}, comptime std.sort.asc(i64));
    std.mem.sort(i64, rar.items, {}, comptime std.sort.asc(i64));
    var sum: i64 = 0;
    for (lar.items, rar.items) |l, r| {
        sum += @intCast(@abs(l - r));
    }

    var sum2: i64 = 0;
    for (lar.items) |l| {
        var op: i64 = 0;
        for (rar.items) |r| {
            if (r == l)
                op += 1;
        }
        sum2 += l * op;
    }
    return .{ .part1 = sum, .part2 = sum2 };
}
