const std = @import("std");

fn checkReport(arr: std.ArrayList(i64)) !bool {
    var asc: ?bool = null;
    var last = arr.items[0];
    for (arr.items[1..]) |next| {
        if (asc) |a| {
            if (a and next < last) {
                return false;
            }
            if (!a and next > last) {
                return false;
            }
        } else {
            asc = if (next > last) true else false;
        }
        const diff = @abs(last - next);
        if (diff < 1 or diff > 3) {
            return false;
        }
        last = next;
    }
    return true;
}

fn initReport(allocator: std.mem.Allocator, inp: []const u8) !std.ArrayList(i64) {
    var nit = std.mem.splitScalar(u8, inp, ' ');
    var arr = std.ArrayList(i64).init(allocator);
    while (nit.next()) |ns| {
        const next = try std.fmt.parseInt(i64, ns, 10);
        try arr.append(next);
    }
    return arr;
}

pub fn solve(allocator: std.mem.Allocator, inp: []const u8) !struct { part1: i64, part2: i64 } {
    var part1: i64 = 0;
    var part2: i64 = 0;
    var lit = std.mem.splitScalar(u8, inp, '\n');
    while (lit.next()) |line| {
        if (line.len == 0)
            break;

        const report = try initReport(allocator, line);
        defer report.deinit();

        const passed = try checkReport(report);
        if (passed) {
            part1 += 1;
        } else {
            var copy = try report.clone();
            defer copy.deinit();
            for (0..report.items.len) |i| {
                const removed = copy.orderedRemove(i);
                if (try checkReport(copy)) {
                    part2 += 1;
                    break;
                } else {
                    try copy.insert(i, removed);
                }
            }
        }
    }
    return .{ .part1 = part1, .part2 = part1 + part2 };
}
