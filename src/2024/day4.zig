const std = @import("std");

fn part1(allocator: std.mem.Allocator, grid: *std.ArrayList([]const u8)) !i64 {
    const rows = grid.items.len;
    const cols = grid.items[0].len;
    const xmas = "XMAS";
    const oss = [6][2]isize{ .{ -1, -1 }, .{ -1, 1 }, .{ 1, -1 }, .{ 1, 1 }, .{ 1, 0 }, .{ -1, 0 } };
    var sum: usize = 0;
    for (grid.items, 0..) |row, i| {
        sum += std.mem.count(u8, row, xmas);
        for (0..cols) |j| {
            ol: for (oss) |os| {
                for (0..4) |m| {
                    const dx = @as(isize, @intCast(i)) + os[0] * @as(isize, @intCast(m));
                    const dy = @as(isize, @intCast(j)) + os[1] * @as(isize, @intCast(m));
                    if (dx < 0 or dx >= rows)
                        continue :ol;
                    if (dy < 0 or dy >= cols)
                        continue :ol;
                    if (grid.items[@intCast(dx)][@intCast(dy)] != xmas[m])
                        continue :ol;
                }
                sum += 1;
            }
        }
        const rev = try allocator.dupe(u8, row);
        defer allocator.free(rev);
        std.mem.reverse(u8, rev);
        sum += std.mem.count(u8, rev, xmas);
    }
    return @intCast(sum);
}

fn xmasCross(tlc: u8, trc: u8, blc: u8, brc: u8) bool {
    return (tlc == 'M' and brc == 'S' and trc == 'M' and blc == 'S') or
        (tlc == 'M' and brc == 'S' and trc == 'S' and blc == 'M') or
        (tlc == 'S' and brc == 'M' and trc == 'M' and blc == 'S') or
        (tlc == 'S' and brc == 'M' and trc == 'S' and blc == 'M');
}

fn part2(grid: *std.ArrayList([]const u8)) i64 {
    var sum: i64 = 0;
    for (1..grid.items.len - 1) |i| {
        for (1..grid.items[0].len - 1) |j| {
            if (grid.items[i][j] != 'A') continue;
            const cs = .{
                grid.items[i - 1][j - 1],
                grid.items[i - 1][j + 1],
                grid.items[i + 1][j - 1],
                grid.items[i + 1][j + 1],
            };
            if (xmasCross(cs[0], cs[1], cs[2], cs[3])) {
                sum += 1;
            }
        }
    }
    return sum;
}

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { part1: i64, part2: i64 } {
    var grid = std.ArrayList([]const u8).init(allocator);
    defer grid.deinit();
    var lit = std.mem.splitScalar(u8, input, '\n');
    while (lit.next()) |line| {
        if (line.len == 0)
            break;
        try grid.append(std.mem.trim(u8, line, " \r\n"));
    }
    return .{
        .part1 = try part1(allocator, &grid),
        .part2 = part2(&grid),
    };
}
