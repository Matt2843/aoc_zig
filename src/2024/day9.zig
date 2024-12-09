const std = @import("std");

fn part1(allocator: std.mem.Allocator, input_t: []const u8) !i64 {
    var parsed = std.ArrayList(i64).init(allocator);
    defer parsed.deinit();
    var file_id: i64 = 0;
    for (input_t, 0..) |c, i| {
        const d = try std.fmt.parseInt(usize, &[_]u8{c}, 10);
        if (i % 2 == 0) {
            try parsed.appendNTimes(file_id, d);
            file_id += 1;
        } else {
            try parsed.appendNTimes(-1, d);
        }
    }
    ol: for (parsed.items, 0..) |s, i| {
        if (s == -1) {
            for (0..parsed.items.len) |j| {
                const ri = parsed.items.len - 1 - j;
                if (ri <= i) break :ol;
                if (parsed.items[ri] != -1) {
                    std.mem.swap(i64, &parsed.items[i], &parsed.items[ri]);
                    break;
                }
            }
        }
    }
    var result: i64 = 0;
    for (parsed.items, 0..) |id, i| {
        if (id == -1) break;
        result += @as(i64, @intCast(i)) * id;
    }
    return result;
}

fn part2(allocator: std.mem.Allocator, input_t: []const u8) !usize {
    var files = std.AutoHashMap(usize, [2]usize).init(allocator);
    defer files.deinit();
    var free = std.ArrayList([2]usize).init(allocator);
    defer free.deinit();

    var file_id: usize = 0;
    var pos: usize = 0;
    for (input_t, 0..) |c, i| {
        const d = try std.fmt.parseInt(usize, &[_]u8{c}, 10);
        if (i % 2 == 0) {
            try files.putNoClobber(file_id, .{ pos, d });
            file_id += 1;
        } else {
            try free.append(.{ pos, d });
        }
        pos += d;
    }

    while (file_id > 0) {
        file_id -= 1;
        const file = files.get(file_id).?;
        for (0..free.items.len) |i| {
            const es = free.items[i];
            if (es[0] >= file[0]) break;
            if (es[1] >= file[1]) {
                try files.put(file_id, .{ es[0], file[1] });
                if (es[1] == file[1]) {
                    _ = free.orderedRemove(i);
                } else if (es[1] > file[1]) {
                    free.items[i] = .{ es[0] + file[1], es[1] - file[1] };
                }
                break;
            }
        }
    }

    var result: usize = 0;
    var items = files.iterator();
    while (items.next()) |file| {
        for (file.value_ptr[0]..file.value_ptr[0] + file.value_ptr[1]) |x| {
            result += x * file.key_ptr.*;
        }
    }
    return result;
}

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { part1: i64, part2: usize } {
    const input_t = std.mem.trim(u8, input, " \r\n");
    return .{
        .part1 = try part1(allocator, input_t),
        .part2 = try part2(allocator, input_t),
    };
}
