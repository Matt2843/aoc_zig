const std = @import("std");
const ds = @import("../ds.zig");

const ParsedInput = struct {
    antennas: std.AutoHashMap(u8, std.ArrayList([2]isize)),
    rows: isize,
    cols: isize,
};

fn parse(allocator: std.mem.Allocator, input: []const u8) !ParsedInput {
    const inp_t = std.mem.trim(u8, input, " \r\n");
    var antennas = std.AutoHashMap(u8, std.ArrayList([2]isize)).init(allocator);

    var lit = std.mem.splitScalar(u8, inp_t, '\n');
    var cols: usize = undefined;
    var row: usize = 0;
    while (lit.next()) |line| : (row += 1) {
        const line_t = std.mem.trim(u8, line, " \r\n");
        cols = line_t.len;
        for (line_t, 0..) |ch, col| {
            if (ch != '.' and ch != '#') {
                const r = try antennas.getOrPut(ch);
                if (!r.found_existing) {
                    r.value_ptr.* = std.ArrayList([2]isize).init(allocator);
                }
                try r.value_ptr.append(.{ @intCast(row), @intCast(col) });
            }
        }
    }
    return .{
        .antennas = antennas,
        .rows = @intCast(row),
        .cols = @intCast(cols),
    };
}

fn inbounds(a: [2]isize, rows: isize, cols: isize) bool {
    return a[0] >= 0 and a[0] < rows and a[1] >= 0 and a[1] < cols;
}

fn anti(allocator: std.mem.Allocator, a1: [2]isize, a2: [2]isize, rows: isize, cols: isize, repeat: bool) !std.AutoHashMap([2]isize, isize) {
    const diff = .{ a1[0] - a2[0], a1[1] - a2[1] };
    var an1 = a1;
    var an2 = a2;
    var map = std.AutoHashMap([2]isize, isize).init(allocator);
    while (true) {
        var updated = false;
        an1 = .{ an1[0] + diff[0], an1[1] + diff[1] };
        an2 = .{ an2[0] - diff[0], an2[1] - diff[1] };
        if (inbounds(an1, rows, cols)) {
            updated = true;
            _ = try map.getOrPutValue(an1, 1);
        }
        if (inbounds(an2, rows, cols)) {
            updated = true;
            _ = try map.getOrPutValue(an2, 1);
        }
        if (!updated or !repeat)
            break;
    }
    return map;
}

fn countAntinodes(parsedInput: ParsedInput, allocator: std.mem.Allocator, pt2: bool) !usize {
    var antinodes = std.AutoHashMap([2]isize, isize).init(allocator);
    defer antinodes.deinit();
    var an_it = parsedInput.antennas.iterator();
    while (an_it.next()) |antenna| {
        var product_it = ds.product([2]isize, antenna.value_ptr.items, 2);
        while (product_it.next()) |p| {
            if (p[0][0] != p[1][0] and p[0][1] != p[1][1]) {
                var antis = try anti(allocator, p[0], p[1], parsedInput.rows, parsedInput.cols, pt2);
                defer antis.deinit();

                var antis_it = antis.keyIterator();
                while (antis_it.next()) |an| _ = try antinodes.getOrPutValue(an.*, 1);
            }
        }
        if (pt2 and antenna.value_ptr.items.len > 1) {
            for (antenna.value_ptr.items) |ant| _ = try antinodes.getOrPutValue(ant, 1);
        }
    }
    var res: usize = 0;
    var it = antinodes.keyIterator();
    while (it.next()) |_| res += 1;
    return res;
}

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct {
    part1: usize,
    part2: usize,
} {
    var r = try parse(allocator, input);
    defer {
        var value_it = r.antennas.valueIterator();
        while (value_it.next()) |arr| arr.deinit();
        r.antennas.clearAndFree();
    }

    return .{
        .part1 = try countAntinodes(r, allocator, false),
        .part2 = try countAntinodes(r, allocator, true),
    };
}
