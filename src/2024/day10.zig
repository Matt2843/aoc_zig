const std = @import("std");

const DIRECTIONS: [4][2]isize = [_][2]isize{ .{ -1, 0 }, .{ 1, 0 }, .{ 0, 1 }, .{ 0, -1 } };
fn bfs(allocator: std.mem.Allocator, grid: *const Grid, start: [2]isize, goal: u8) ![][2]isize {
    var goals = std.ArrayList([2]isize).init(allocator);
    var queue = std.fifo.LinearFifo([2]isize, .Dynamic).init(allocator);
    defer queue.deinit();
    try queue.writeItem(start);
    while (queue.readItem()) |item| {
        if (grid.buffer[@intCast(item[0])][@intCast(item[1])] == goal) {
            try goals.append(item);
            continue;
        }
        for (DIRECTIONS) |dir| {
            const nx = item[0] + dir[0];
            const ny = item[1] + dir[1];
            if (nx >= 0 and nx < grid.buffer.len and ny >= 0 and ny < grid.buffer[0].len) {
                const num = try std.fmt.parseInt(isize, &[_]u8{grid.buffer[@intCast(item[0])][@intCast(item[1])]}, 10);
                const nxt = try std.fmt.parseInt(isize, &[_]u8{grid.buffer[@intCast(nx)][@intCast(ny)]}, 10);
                if (nxt - num == 1) {
                    try queue.writeItem(.{ nx, ny });
                }
            }
        }
    }
    return try goals.toOwnedSlice();
}

fn unique(allocator: std.mem.Allocator, comptime T: type, slice: []T) ![]T {
    var map = std.AutoHashMap(T, ?void).init(allocator);
    defer map.deinit();
    for (slice) |s| {
        try map.put(s, null);
    }
    var arr = std.ArrayList(T).init(allocator);
    var key_it = map.keyIterator();
    while (key_it.next()) |k| try arr.append(k.*);
    return arr.toOwnedSlice();
}

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { part1: usize, part2: usize } {
    var grid = try Grid.init(allocator, input);
    defer grid.deinit();
    var start_it = grid.positions('0');
    var part1: usize = 0;
    var part2: usize = 0;
    while (start_it.next()) |start| {
        const goals = try bfs(allocator, &grid, .{ @intCast(start[0]), @intCast(start[1]) }, '9');
        defer allocator.free(goals);
        const distinct_goals = try unique(allocator, [2]isize, goals);
        defer allocator.free(distinct_goals);
        part1 += distinct_goals.len;
        part2 += goals.len;
    }
    return .{ .part1 = part1, .part2 = part2 };
}

const Grid = struct {
    allocator: std.mem.Allocator,
    buffer: [][]const u8 = undefined,

    const Self = @This();

    fn init(allocator: std.mem.Allocator, str: []const u8) !Self {
        const trimmed = std.mem.trim(u8, str, " \r\n");
        var buffer = std.ArrayList([]const u8).init(allocator);
        defer buffer.deinit();
        var line_iterator = std.mem.splitScalar(u8, trimmed, '\n');
        while (line_iterator.next()) |line| {
            const t_line = std.mem.trim(u8, line, " \r\n");
            try buffer.append(t_line);
        }
        return .{ .allocator = allocator, .buffer = try buffer.toOwnedSlice() };
    }

    const PositionIterator = struct {
        buffer: [][]const u8,
        needle: u8,
        index: usize = 0,
        inner_index: usize = 0,
        fn next(self: *PositionIterator) ?[2]usize {
            for (self.index..self.buffer.len) |row| {
                for (self.inner_index..self.buffer[0].len) |col| {
                    if (self.buffer[row][col] == self.needle) {
                        self.index = row;
                        self.inner_index = col + 1;
                        return .{ row, col };
                    }
                }
                self.inner_index = 0;
            }
            return null;
        }
    };

    fn positions(self: *const Self, needle: u8) PositionIterator {
        return .{ .buffer = self.buffer, .needle = needle };
    }

    fn deinit(self: *Self) void {
        self.allocator.free(self.buffer);
    }
};
