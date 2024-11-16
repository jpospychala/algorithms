const std = @import("std");

fn add(a: []const u8, b: []const u8, alloc: std.mem.Allocator) ![]u8 {
    const anum = try std.fmt.parseInt(usize, a, 2);
    const bnum = try std.fmt.parseInt(usize, b, 2);
    const c = anum + bnum;
    return try std.fmt.allocPrint(alloc, "{b}", .{c});
}

test {
    const actual = try add("001", "010", std.testing.allocator);
    defer std.testing.allocator.free(actual);

    try std.testing.expectEqualStrings("11", actual);
}
