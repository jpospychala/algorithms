const std = @import("std");
const testing = std.testing;

const IPv7 = struct {
    supernets: std.ArrayList([]const u8),
    hypernets: std.ArrayList([]const u8),

    fn init(buf: []const u8, allocator: std.mem.Allocator) !IPv7 {
        var result = IPv7{
            .supernets = std.ArrayList([]const u8).init(allocator),
            .hypernets = std.ArrayList([]const u8).init(allocator),
        };
        var supernetStart: usize = 0;
        var hypernetStart: ?usize = 0;

        while (true) {
            hypernetStart = std.mem.indexOfScalarPos(u8, buf, supernetStart, '[');
            if (hypernetStart != null) {
                try result.supernets.append(buf[supernetStart..hypernetStart.?]);
                const hypernetEnd = std.mem.indexOfScalarPos(u8, buf, hypernetStart.?, ']');
                if (hypernetEnd != null) {
                    try result.hypernets.append(buf[hypernetStart.? + 1 .. hypernetEnd.?]);
                    supernetStart = hypernetEnd.? + 1;
                }
            } else {
                if (supernetStart > 0) {
                    try result.supernets.append(buf[supernetStart..]);
                }
                break;
            }
        }
        return result;
    }

    fn isSSL(self: IPv7) bool {
        for (self.supernets.items) |supernet| {
            for (0..supernet.len - 2) |i| {
                if (supernet[i] == supernet[i + 2] and supernet[i] != supernet[i + 1]) {
                    const a = supernet[i];
                    const b = supernet[i + 1];
                    for (self.hypernets.items) |hypernet| {
                        for (0..hypernet.len - 2) |j| {
                            if (hypernet[j] == hypernet[j + 2] and hypernet[j] == b and hypernet[j + 1] == a) {
                                std.debug.print("{s} {s}\n", .{ supernet[i .. i + 3], hypernet[j .. j + 3] });
                                return true;
                            }
                        }
                    }
                }
            }
        }

        return false;
    }

    fn deinit(self: IPv7) void {
        self.hypernets.deinit();
        self.supernets.deinit();
    }
};

test "IPv7.init empty" {
    const ipv7 = try IPv7.init("", testing.allocator);
    defer ipv7.deinit();

    try testing.expectEqual(0, ipv7.supernets.items.len);
    try testing.expectEqual(0, ipv7.hypernets.items.len);
}

test "IPv7.init" {
    const ipv7 = try IPv7.init("abba[mnop]qrst", testing.allocator);
    defer ipv7.deinit();

    try testing.expectEqual(2, ipv7.supernets.items.len);
    try testing.expectEqualStrings(ipv7.supernets.items[0], "abba");
    try testing.expectEqualStrings(ipv7.supernets.items[1], "qrst");
    try testing.expectEqual(1, ipv7.hypernets.items.len);
    try testing.expectEqualStrings(ipv7.hypernets.items[0], "mnop");
}

test "IPv7.isSSL" {
    const ipv7 = try IPv7.init("aba[bab]xyz", testing.allocator);
    defer ipv7.deinit();

    try testing.expect(ipv7.isSSL());
}

test "IPv7.isSSL 2" {
    const ipv7 = try IPv7.init("zazbz[bzb]cdb", testing.allocator);
    defer ipv7.deinit();

    try testing.expect(ipv7.isSSL());
}

test "aoc input" {
    var file = try std.fs.cwd().openFile("aoc2016_07.txt", .{});
    defer file.close();

    const reader = file.reader();
    var buf = [_]u8{0} ** 4096;
    var count: usize = 0;
    while (true) {
        const slice = reader.readUntilDelimiter(&buf, '\n');
        if (slice == error.EndOfStream) {
            break;
        }
        const ipv7 = try IPv7.init(try slice, testing.allocator);
        defer ipv7.deinit();

        if (ipv7.isSSL()) {
            count += 1;
            std.debug.print("{s}\n", .{try slice});
        }
    }
    try testing.expectEqual(258, count);
}
