const std = @import("std");

fn parseRules(allocator: std.mem.Allocator, rules: []const u8) !std.AutoHashMap(i64, std.ArrayList(i64)) {
    var output = std.AutoHashMap(i64, std.ArrayList(i64)).init(allocator);
    var lit = std.mem.tokenizeAny(u8, rules, "|\n");
    while (lit.next()) |lhs| {
        if (lhs.len == 0)
            break;
        const rhs = std.mem.trim(u8, lit.next().?, "\r\n ");
        const lhsd = try std.fmt.parseInt(i64, lhs, 10);
        const rhsd = try std.fmt.parseInt(i64, rhs, 10);

        const gopr = try output.getOrPut(lhsd);
        if (!gopr.found_existing) {
            gopr.value_ptr.* = std.ArrayList(i64).init(allocator);
        }
        try gopr.value_ptr.append(rhsd);
    }
    return output;
}

fn parsePages(allocator: std.mem.Allocator, pages: []const u8) !std.ArrayList(std.ArrayList(i64)) {
    var output = std.ArrayList(std.ArrayList(i64)).init(allocator);
    var page_it = std.mem.splitScalar(u8, pages, '\n');
    while (page_it.next()) |page| {
        if (page.len == 0)
            break;
        var num_it = std.mem.splitScalar(u8, page, ',');
        var nums = std.ArrayList(i64).init(allocator);
        while (num_it.next()) |n| {
            const num = try std.fmt.parseInt(i64, n, 10);
            try nums.append(num);
        }
        try output.append(nums);
    }
    return output;
}

fn pageOk(rules: *const std.AutoHashMap(i64, std.ArrayList(i64)), page: []i64) ?i64 {
    var mid_num: i64 = undefined;
    for (page, 0..) |num, num_i| {
        const rules_for_num = rules.get(num);
        if (rules_for_num) |rfn| {
            if (std.mem.indexOfAny(i64, page, rfn.items)) |ri| {
                if (ri < num_i) {
                    return null;
                }
            }
        }
        if (num_i == page.len / 2)
            mid_num = num;
    }
    return mid_num;
}

fn pageFix(rules: *const std.AutoHashMap(i64, std.ArrayList(i64)), page: []i64) i64 {
    var swapped = true;
    while (swapped) {
        swapped = false;
        for (0..page.len - 1) |i| {
            if (rules.get(page[i])) |rs| {
                if (std.mem.indexOf(i64, rs.items, &[_]i64{page[i + 1]}) == null) {
                    std.mem.swap(i64, &page[i], &page[i + 1]);
                    swapped = true;
                }
            }
        }
    }
    return page[page.len / 2];
}

pub fn solve(allocator: std.mem.Allocator, input: []const u8) !struct { part1: i64, part2: i64 } {
    var nn_it = std.mem.splitSequence(u8, input, "\n\n");

    // TODO: Doesn't work with \r\n (windows line-endings..)
    var rules = try parseRules(allocator, nn_it.next().?);
    defer {
        var values_it = rules.valueIterator();
        while (values_it.next()) |arr| arr.deinit();
        rules.clearAndFree();
    }
    var pages = try parsePages(allocator, nn_it.next().?);
    defer {
        for (pages.items) |page| page.deinit();
        pages.clearAndFree();
    }

    var part1: i64 = 0;
    var part2: i64 = 0;
    for (pages.items) |page| {
        if (pageOk(&rules, page.items)) |mid| {
            part1 += mid;
        } else {
            part2 += pageFix(&rules, page.items);
        }
    }

    return .{
        .part1 = part1,
        .part2 = part2,
    };
}
