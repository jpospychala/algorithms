const std = @import("std");

fn add(a: []const u8, b: []const u8, alloc: std.mem.Allocator) ![]u8 {
    const anum = try std.fmt.parseInt(usize, a, 2);
    const bnum = try std.fmt.parseInt(usize, b, 2);
    const c = anum + bnum;
    return try std.fmt.allocPrint(alloc, "{b}", .{c});
}

fn add2(a: []const u8, b: []const u8, alloc: std.mem.Allocator) ![]u8 {
    var n = @max(a.len, b.len);
    var rem: u8 = 0;
    const result = try alloc.alloc(u8, n + 1);

    for (0..n) |i| {
        const abit: u8 = if (a.len > i) a[a.len - i - 1] else '0';
        const bbit: u8 = if (b.len > i) b[b.len - i - 1] else '0';
        var sum = abit + bbit - '0' - '0' + rem;
        rem = sum / 2;
        sum = sum % 2;
        result[n - i] = sum + '0';
    }

    if (rem > 0) {
        result[0] = '1';
        n = n + 1;
    } else {
        for (0..n) |i| {
            result[i] = result[i + 1];
        }
        _ = alloc.resize(result, n);
    }

    return result[0..n];
}

test "01+10=11" {
    const actual = try add2("01", "10", std.testing.allocator);
    defer std.testing.allocator.free(actual);

    try std.testing.expectEqualStrings("11", actual);
}

test "1+1=10" {
    const actual = try add2("1", "1", std.testing.allocator);
    defer std.testing.allocator.free(actual);

    try std.testing.expectEqualStrings("10", actual);
}

test "11+11=110" {
    const actual = try add2("11", "11", std.testing.allocator);
    defer std.testing.allocator.free(actual);

    try std.testing.expectEqualStrings("110", actual);
}

test "1111111+1=10000000" {
    const actual = try add2("1111111", "1", std.testing.allocator);
    defer std.testing.allocator.free(actual);

    try std.testing.expectEqualStrings("10000000", actual);
}
