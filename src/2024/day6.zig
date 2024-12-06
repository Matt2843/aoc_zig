const std = @import("std");
const ds = @import("../ds.zig");

const dirs: [4][2]isize = .{ .{ -1, 0 }, .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 } };
fn loops(visited: *std.AutoHashMap([4]isize, usize), grid: *const std.ArrayList([]const u8), sx: isize, sy: isize, ox: isize, oy: isize) !bool {
    _ = try visited.putNoClobber(.{ sx, sy, dirs[0][0], dirs[0][1] }, 1);
    var pos_x: isize = sx;
    var pos_y: isize = sy;
    var dir_i: usize = 0;
    var loop = false;
    while (true) {
        const dir: [2]isize = dirs[dir_i];
        const nx = pos_x + dir[0];
        const ny = pos_y + dir[1];

        if (nx < 0 or ny < 0 or nx >= grid.items.len or ny >= grid.items[0].len) {
            break;
        }

        if (nx == ox and ny == oy or grid.items[@intCast(nx)][@intCast(ny)] == '#') {
            dir_i = try std.math.mod(usize, dir_i + 1, 4);
            continue;
        }

        const r = try visited.getOrPut(.{ nx, ny, dir[0], dir[1] });
        if (r.found_existing) {
            loop = true;
            break;
        }
        pos_x = nx;
        pos_y = ny;
    }
    return loop;
}

fn guardDistinctPositions(allocator: std.mem.Allocator, grid: *const std.ArrayList([]const u8), sx: isize, sy: isize) !std.AutoHashMap([2]isize, usize) {
    var visited = std.AutoHashMap([2]isize, usize).init(allocator);
    _ = try visited.putNoClobber(.{ sx, sy }, 1);
    var pos_x: isize = sx;
    var pos_y: isize = sy;
    var dir_i: usize = 0;
    while (true) {
        const dir: [2]isize = dirs[dir_i];
        const nx = pos_x + dir[0];
        const ny = pos_y + dir[1];

        if (nx < 0 or ny < 0 or nx >= grid.items.len or ny >= grid.items[0].len) {
            break;
        }

        if (grid.items[@intCast(nx)][@intCast(ny)] == '#') {
            dir_i = try std.math.mod(usize, dir_i + 1, 4);
            continue;
        }

        _ = try visited.getOrPut(.{ nx, ny });
        pos_x = nx;
        pos_y = ny;
    }
    return visited;
}

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { part1: i64, part2: i64 } {
    const grid = try ds.Grid2.init(allocator, input);
    defer grid.deinit();

    var pos_x: isize = undefined;
    var pos_y: isize = undefined;
    for (grid.items.items, 0..) |row, i| {
        if (std.mem.indexOf(u8, row, &[_]u8{'^'})) |start| {
            pos_x = @intCast(i);
            pos_y = @intCast(start);
            break;
        }
    }

    var guardRoute = try guardDistinctPositions(allocator, &grid.items, pos_x, pos_y);
    defer guardRoute.deinit();

    var visited = std.AutoHashMap([4]isize, usize).init(allocator);
    defer visited.deinit();

    var part1: i64 = 0;
    var part2: i64 = 0;
    var key_it = guardRoute.keyIterator();
    while (key_it.next()) |pos| {
        part1 += 1;
        visited.clearRetainingCapacity();
        if (try loops(&visited, &grid.items, pos_x, pos_y, pos[0], pos[1]))
            part2 += 1;
    }
    return .{ .part1 = part1, .part2 = part2 };
}
