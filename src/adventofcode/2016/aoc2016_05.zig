const std = @import("std");
const testing = std.testing;

fn passGen(seed: []const u8, out: []u8) !void {
    var seedBuf = [_]u8{0} ** 128;
    var hashHexBuf = [_]u8{0} ** 128;
    var hash = [_]u8{0} ** 16;
    var c: usize = 0;

    for (0..8) |i| {
        while (true) {
            const seedn = try std.fmt.bufPrint(&seedBuf, "{s}{d}", .{ seed, c });
            c += 1;
            std.crypto.hash.Md5.hash(seedn, &hash, .{});
            const hashHex = try std.fmt.bufPrint(&hashHexBuf, "{s}", .{std.fmt.fmtSliceHexLower(&hash)});
            if (std.mem.eql(u8, hashHex[0..5], "00000")) {
                out[i] = hashHex[5];
                std.debug.print("{s} {s} {s}\n", .{ seedn, hashHex, out });
                break;
            }
        }
    }
}

//test "passGen" {
//    var buf = [_]u8{0} ** 8;
//    try passGen("abc", &buf);
//    try testing.expectEqualSlices(u8, "18f47a30", &buf);
//}

test "passGen" {
    var buf = [_]u8{0} ** 8;
    try passGen("ojvtpuvg", &buf);
    try testing.expectEqualSlices(u8, "4543c154", &buf);
}
