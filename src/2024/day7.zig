const std = @import("std");
const ds = @import("../ds.zig");

fn eval(ops: []const u8, in: []const i64) i64 {
    var res: i64 = in[0];
    var i: usize = 1;
    for (ops) |op| {
        switch (op) {
            '+' => res += in[i],
            '*' => res *= in[i],
            '|' => res = concatenateNumbers(res, in[i]),
            else => {},
        }
        i += 1;
    }
    return res;
}

fn concatenateNumbers(a: i64, b: i64) i64 {
    var temp = b;
    var b_digits: i64 = 0;
    while (temp > 0) : (temp = @divFloor(temp, 10)) b_digits += 1;
    return a * std.math.pow(i64, 10, b_digits) + b;
}

pub fn solve(_: std.mem.Allocator, input: []const u8) !struct {
    part1: i64,
    part2: i64,
} {
    var part1: i64 = 0;
    var part2: i64 = 0;
    const operators = [_]u8{ '+', '*' };
    const operators2 = [_]u8{ '+', '*', '|' };
    const trimmed_input = std.mem.trim(u8, input, " \r\n");
    var lit = std.mem.splitScalar(u8, trimmed_input, '\n');
    while (lit.next()) |line| {
        const trimmed_line = std.mem.trim(u8, line, " \r\n");
        var inp_it = std.mem.splitSequence(u8, trimmed_line, ": ");
        const lhs = try std.fmt.parseInt(i64, inp_it.next().?, 10);

        const vals = inp_it.next().?;
        var split_it = std.mem.splitScalar(u8, vals, ' ');

        var buffer = [_]i64{0} ** 100;
        var buffer_i: usize = 0;
        while (split_it.next()) |num| {
            const val = try std.fmt.parseInt(i64, num, 10);
            buffer[buffer_i] = val;
            buffer_i += 1;
        }

        var cartesian = ds.product(u8, &operators, buffer_i - 1);
        while (cartesian.next()) |ops| {
            const rhs = eval(ops, buffer[0..buffer_i]);
            if (rhs == lhs) {
                part1 += lhs;
                break;
            }
        }
        var cartesian2 = ds.product(u8, &operators2, buffer_i - 1);
        while (cartesian2.next()) |ops| {
            const rhs = eval(ops, buffer[0..buffer_i]);
            if (rhs == lhs) {
                part2 += lhs;
                break;
            }
        }
    }

    return .{
        .part1 = part1,
        .part2 = part2,
    };
}
