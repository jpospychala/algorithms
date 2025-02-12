const std = @import("std");

fn numlen(n: usize) usize {
    var v = n;
    var count: usize = 0;
    while (v > 0) {
        count += 1;
        v = v / 10;
    }
    return count;
}

fn blink(stones: *std.ArrayList(usize)) !void {
    var i: usize = 0;
    while (i < stones.items.len) {
        const s = stones.items[i];
        const len = numlen(s);
        if (s == 0) {
            stones.items[i] = 1;
        } else if (@mod(len, 2) == 0) {
            var m: usize = 1;
            for (0..len / 2) |_| {
                m *= 10;
            }
            const lefthalf = s / m;
            const righthalf = @mod(s, m);
            stones.items[i] = righthalf;
            try stones.insert(i, lefthalf);
            i += 1;
        } else {
            stones.items[i] = s * 2024;
        }
        i += 1;
    }
}

fn blinkN(stones: *std.ArrayList(usize), n: usize) !void {
    for (0..n) |_| {
        try blink(stones);
        //   std.debug.print("{any}\n", .{stones.items});
    }
}

fn parse(in: []const u8, a: std.mem.Allocator) !std.ArrayList(usize) {
    var tok = std.mem.tokenizeScalar(u8, in, ' ');
    var l = std.ArrayList(usize).init(a);
    while (tok.next()) |n| {
        const num = try std.fmt.parseUnsigned(usize, n, 10);
        try l.append(num);
    }
    return l;
}

test "1" {
    var items = try parse("125 17", std.testing.allocator);
    defer items.deinit();
    try blinkN(&items, 6);
    const expected = [_]usize{ 2097446912, 14168, 4048, 2, 0, 2, 4, 40, 48, 2024, 40, 48, 80, 96, 2, 8, 6, 7, 6, 0, 3, 2 };

    try std.testing.expectEqualSlices(usize, expected[0..], items.items);
}

test "2" {
    var items = try parse("125 17", std.testing.allocator);
    defer items.deinit();
    try blinkN(&items, 25);
    try std.testing.expectEqual(55312, items.items.len);
}

test "part one, final input" {
    var items = try parse("9759 0 256219 60 1175776 113 6 92833", std.testing.allocator);
    defer items.deinit();
    try blinkN(&items, 25);
    try std.testing.expectEqual(186996, items.items.len);
}
