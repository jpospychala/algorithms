const std = @import("std");
const testing = std.testing;

const IPv7 = struct {
    fn hasTLS(buf: []const u8) bool {
        return IPv7._hasTLS(buf, false);
    }

    fn _hasTLS(buf: []const u8, alreadyAbba: bool) bool {
        // std.debug.print("hasTLS {s}\n", .{buf});
        const hStartIdx = std.mem.indexOfScalar(u8, buf, '[');
        if (hStartIdx != null) {
            //   std.debug.print("hStartIdx\n", .{});
            const hEndIdx = std.mem.indexOfScalarPos(u8, buf, hStartIdx.?, ']').?;
            const nowAbba = IPv7.hasAbba(buf[0..hStartIdx.?]) or alreadyAbba;
            return !IPv7.hasAbba(buf[hStartIdx.?..hEndIdx]) and _hasTLS(buf[hEndIdx + 1 ..], nowAbba);
        } else {
            return IPv7.hasAbba(buf) or alreadyAbba;
        }
    }

    fn hasAbba(buf: []const u8) bool {
        var ret: bool = false;
        for (0..buf.len - 3) |i| {
            if (buf[i] == buf[i + 3] and buf[i + 1] == buf[i + 2] and buf[i] != buf[i + 1]) {
                ret = true;
                break;
            }
        }
        //   std.debug.print("hasAbba {s} {}\n", .{ buf, ret });
        return ret;
    }
};

test "IPv7 hasTLS" {
    try testing.expectEqual(true, IPv7.hasTLS("abba[mnop]qrst"));
    try testing.expectEqual(false, IPv7.hasTLS("abcd[bddb]xyyx"));
    try testing.expectEqual(false, IPv7.hasTLS("aaaa[qwer]tyui"));
    try testing.expectEqual(true, IPv7.hasTLS("ioxxoj[asdfgh]zxcvbn"));
    try testing.expectEqual(false, IPv7.hasTLS("axax[bdda]aaia[bddb]ioxxoj"));
    try testing.expectEqual(false, IPv7.hasTLS("axax[bdda]ioxxoj[bddb]"));
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
        if (IPv7.hasTLS(try slice)) {
            count += 1;
            std.debug.print("{s}\n", .{try slice});
        }
    }
    try testing.expectEqual(105, count);
}
