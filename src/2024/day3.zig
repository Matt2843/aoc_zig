const std = @import("std");

fn mul(tok: []const u8) !i64 {
    if (!std.mem.startsWith(u8, tok, "("))
        return 0;
    var num_arr = [_]u8{0} ** 100;
    var num_arr_i: usize = 0;
    var lop: i64 = 0;
    var rop: i64 = 0;
    for (tok[1..]) |c| {
        const digit = std.ascii.isDigit(c);
        if (c != ',' and !digit and c != ')')
            return 0;
        if (digit) {
            num_arr[num_arr_i] = c;
            num_arr_i += 1;
        } else if (c == ',' and num_arr_i != 0) {
            lop = try std.fmt.parseInt(i64, num_arr[0..num_arr_i], 10);
            num_arr_i = 0;
        } else if (c == ')' and num_arr_i != 0 and lop != 0) {
            rop = try std.fmt.parseInt(i64, num_arr[0..num_arr_i], 10);
            break;
        }
    }
    return lop * rop;
}

fn do(tok: []const u8) ?bool {
    const dont_i = std.mem.indexOf(u8, tok, "don't()") orelse 0;
    const do_i = std.mem.indexOf(u8, tok, "do()") orelse 0;
    return if (do_i != 0 or dont_i != 0) do_i > dont_i else null;
}

pub fn solve(_: std.mem.Allocator, inp: []const u8) !struct { part1: i64, part2: i64 } {
    var part1: i64 = 0;
    var part2: i64 = 0;
    var incl = true;
    var mul_it = std.mem.tokenizeSequence(u8, inp, "mul");
    while (mul_it.next()) |tok| {
        const m = try mul(tok);
        part1 += m;
        if (incl) part2 += m;
        incl = do(tok) orelse incl;
    }
    return .{ .part1 = part1, .part2 = part2 };
}

test {
    const hay = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";
    const sol = try solve(std.testing.allocator, hay);
    std.debug.print("\n{any}\n", .{sol});
    try std.testing.expect(sol.part1 == 48);
}
