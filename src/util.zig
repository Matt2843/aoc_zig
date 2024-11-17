const std = @import("std");
const session = @embedFile(".aoc_session");

pub fn getInput(allocator: std.mem.Allocator, year: u32, day: u32) ![]const u8 {
    const path = try std.fmt.allocPrint(allocator, ".cache/{d}/{d}.in", .{ year, day });
    defer allocator.free(path);

    return readCache(allocator, path) catch return downloadInput(allocator, year, day, path);
}

fn readCache(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const stat = try file.stat();
    return try file.readToEndAlloc(allocator, stat.size);
}

fn writeCache(path: []const u8, content: *const []u8) !void {
    const dir = std.fs.path.dirname(path).?;
    try std.fs.cwd().makePath(dir);

    var file = try std.fs.cwd().createFile(path, .{ .exclusive = true });
    defer file.close();
    try file.writeAll(content.*);
}

fn downloadInput(allocator: std.mem.Allocator, year: u32, day: u32, path: []const u8) ![]const u8 {
    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    const uri_str = try std.fmt.allocPrint(allocator, "https://adventofcode.com/{d}/day/{d}/input", .{ year, day });
    defer allocator.free(uri_str);

    const uri = try std.Uri.parse(uri_str);
    const buf = try allocator.alloc(u8, 1024 * 1024 * 4);
    defer allocator.free(buf);
    var req = try client.open(.GET, uri, .{
        .server_header_buffer = buf,
    });
    defer req.deinit();

    const session_cookie = try std.fmt.allocPrint(allocator, "session={s}", .{session});
    defer allocator.free(session_cookie);

    const headers = [_]std.http.Header{.{ .name = "Cookie", .value = session_cookie }};
    req.extra_headers = &headers;

    try req.send();
    try req.finish();
    try req.wait();

    try std.testing.expectEqual(.ok, req.response.status);

    var rdr = req.reader();
    const body = try rdr.readAllAlloc(allocator, 1024 * 1024 * 4);

    try writeCache(path, &body);
    std.debug.print("read from web\n", .{});
    return body;
}
