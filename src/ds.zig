const std = @import("std");

pub const Grid2 = struct {
    items: std.ArrayList([]const u8),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, str: []const u8) !Grid2 {
        var items = std.ArrayList([]const u8).init(allocator);
        var lit = std.mem.splitScalar(u8, str, '\n');
        while (lit.next()) |line| {
            if (line.len == 0)
                break;
            const trimmed = std.mem.trim(u8, line, " \r\n");
            try items.append(trimmed);
        }
        return .{ .items = items };
    }

    pub fn deinit(self: Self) void {
        self.items.deinit();
    }

    pub const NumIterator = struct {
        grid: *const Grid2,
        row: usize,
        col: usize,

        pub fn next(self: *NumIterator, comptime T: type) !?T {
            const n = try nextWI(self, T);
            if (n) |nu| return nu.num;
            return null;
        }

        pub fn nextWI(self: *NumIterator, comptime T: type) !?struct { num: T, x: usize, y0: usize, yn: usize } {
            if (self.row >= self.grid.items.items.len)
                return null;
            var w = false;
            var num_i: usize = 0;
            var num_b: [50]u8 = [_]u8{0} ** 50;
            for (self.grid.items.items[self.row][self.col..], 0..) |ch, o| {
                const id = std.ascii.isDigit(ch);
                if (w and !id) {
                    self.col += o;
                    const ret = .{ .num = try std.fmt.parseInt(T, num_b[0..num_i], 10), .x = self.row, .y0 = self.col - num_i, .yn = self.col };
                    return ret;
                }
                if (id) {
                    w = true;
                    num_b[num_i] = ch;
                    num_i += 1;
                }
            }
            self.col = 0;
            if (w) {
                const len = self.grid.items.items[self.row].len;
                const ret = .{ .num = try std.fmt.parseInt(T, num_b[0..num_i], 10), .x = self.row, .y0 = len - num_i, .yn = len };
                self.row += 1;
                return ret;
            }
            self.row += 1;
            return self.nextWI(T);
        }

        pub fn reset(self: *NumIterator) void {
            self.row = 0;
            self.col = 0;
        }
    };

    pub fn nums(self: *const Self) NumIterator {
        return .{
            .grid = self,
            .row = 0,
            .col = 0,
        };
    }

    const offsets: [8][2]isize = .{ .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 }, .{ 0, -1 }, .{ 0, 1 }, .{ 1, -1 }, .{ 1, 0 }, .{ 1, 1 } };
    pub fn adjacentPos(self: *const Self, x: usize, y: usize, char: u8) ?[2]usize {
        for (offsets) |o| {
            const dx = @as(isize, @intCast(x)) + o[0];
            if (dx < 0 or dx >= self.items.items.len)
                continue;
            const dy = @as(isize, @intCast(y)) + o[1];
            if (dy < 0 or dy >= self.items.items[0].len)
                continue;
            if (self.items.items[@intCast(dx)][@intCast(dy)] == char)
                return .{ @intCast(dx), @intCast(dy) };
        }
        return null;
    }

    pub fn isAdjacentFn(self: *const Self, x: usize, y: usize, comptime f: fn (u8) bool) bool {
        for (offsets) |o| {
            const dx = @as(isize, @intCast(x)) + o[0];
            if (dx < 0 or dx >= self.items.items.len)
                continue;
            const dy = @as(isize, @intCast(y)) + o[1];
            if (dy < 0 or dy >= self.items.items[0].len)
                continue;
            if (f(self.items.items[@intCast(dx)][@intCast(dy)]))
                return true;
        }
        return false;
    }

    pub fn isAdjacentSequence(self: *const Self, x: usize, y: usize, chars: []const u8) bool {
        const Fns = struct {
            fn inSequence(ch: u8) bool {
                for (chars) |c| {
                    if (ch == c)
                        return true;
                }
                return false;
            }
        };
        return isAdjacentFn(self, x, y, Fns.inSequence);
    }

    pub fn isAdjacentScalar(self: *const Self, x: usize, y: usize, char: u8) bool {
        const Fns = struct {
            fn equals(ch: u8) bool {
                return ch == char;
            }
        };
        return isAdjacentFn(self, x, y, Fns.equals);
    }

    pub fn manhattenD(x1: usize, y1: usize, x2: usize, y2: usize) usize {
        return @abs(x1 - x2) + @abs(y1 - y2);
    }
};
