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

fn Node(comptime T: type) type {
    return struct {
        v: T,
        next: ?*Node(T) = null,

        fn len(self: *@This()) usize {
            var this: ?*@This() = self;
            var result: usize = 0;
            while (this) |t| {
                this = t.next;
                result += 1;
            }
            return result;
        }

        fn deinit(self: *@This(), a: std.mem.Allocator) void {
            const next = self.next;
            a.destroy(self);
            if (next) |n| {
                n.deinit(a);
            }
        }
    };
}

fn blink(stone: usize, n: usize, cache: *std.AutoHashMap([2]usize, usize)) !usize {
    if (n == 0) {
        return 1;
    }

    const k: [2]usize = [2]usize{ stone, n };
    if (cache.get(k)) |v| {
        return v;
    }

    const len = numlen(stone);
    var ret: usize = 0;
    if (stone == 0) {
        ret = try blink(1, n - 1, cache);
    } else if (@mod(len, 2) == 0) {
        var m: usize = 1;
        for (0..len / 2) |_| {
            m *= 10;
        }
        const lefthalf = stone / m;
        const righthalf = @mod(stone, m);
        ret = try blink(lefthalf, n - 1, cache) + try blink(righthalf, n - 1, cache);
    } else {
        ret = try blink(stone * 2024, n - 1, cache);
    }

    try cache.put(k, ret);
    return ret;
}

fn blinkN(stones: *Node(usize), n: usize, a: std.mem.Allocator) !usize {
    var cache = std.AutoHashMap([2]usize, usize).init(a);
    defer cache.deinit();
    var result: usize = 0;
    var curr: ?*Node(usize) = stones;
    while (curr) |stone| {
        result += try blink(stone.v, n, &cache);
        curr = stone.next;
    }
    return result;
}

fn parse(in: []const u8, a: std.mem.Allocator) !?*Node(usize) {
    var tok = std.mem.tokenizeScalar(u8, in, ' ');
    var h: ?*Node(usize) = null;
    var curr: ?*Node(usize) = null;
    while (tok.next()) |n| {
        const num = try std.fmt.parseUnsigned(usize, n, 10);
        var node = try a.create(Node(usize));
        node.v = num;
        node.next = null;
        if (h == null) {
            h = node;
            curr = node;
        } else {
            if (curr) |c| {
                c.*.next = node;
                curr = node;
            }
        }
    }
    return h;
}

//test "1" {
//    const items = try parse("125 17");
//    blinkN(items.?, 6);
//    const expected = [_]usize{ 2097446912, 14168, 4048, 2, 0, 2, 4, 40, 48, 2024, 40, 48, 80, 96, 2, 8, 6, 7, 6, 0, 3, 2 };
//
//    try std.testing.expectEqualSlices(usize, expected[0..], items.items);
//}

test "2" {
    const items = try parse("125 17", std.testing.allocator);
    defer items.?.deinit(std.testing.allocator);
    std.debug.print("{any}\n", .{items});
    const actual = try blinkN(items.?, 25, std.testing.allocator);
    try std.testing.expectEqual(55312, actual);
}

test "part one, final input" {
    const items = try parse("9759 0 256219 60 1175776 113 6 92833", std.testing.allocator);
    defer items.?.deinit(std.testing.allocator);
    const actual = try blinkN(items.?, 25, std.testing.allocator);
    try std.testing.expectEqual(186996, actual);
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    const a = alloc.allocator();
    defer _ = alloc.deinit();
    const items = try parse("9759 0 256219 60 1175776 113 6 92833", a);
    defer items.?.deinit(a);
    const actual = try blinkN(items.?, 75, a);
    std.debug.print("{any}\n", .{actual});
}
