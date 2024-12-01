const std = @import("std");
const testing = std.testing;

fn passGen(seed: []const u8, out: []u8) !void {
    var seedBuf = [_]u8{0} ** 128;
    var hashHexBuf = [_]u8{0} ** 128;
    var hash = [_]u8{0} ** 16;
    var c: usize = 0;
    var missing: usize = 8;

    while (true) {
        const seedn = try std.fmt.bufPrint(&seedBuf, "{s}{d}", .{ seed, c });
        c += 1;
        std.crypto.hash.Md5.hash(seedn, &hash, .{});
        const hashHex = try std.fmt.bufPrint(&hashHexBuf, "{s}", .{std.fmt.fmtSliceHexLower(&hash)});
        if (std.mem.eql(u8, hashHex[0..5], "00000")) {
            const idx = hashHex[5] - '0';
            if (idx < out.len) {
                if (out[idx] == '_') {
                    out[idx] = hashHex[6];
                    missing -= 1;
                }
                std.debug.print("{s} {s} {s}\n", .{ seedn, hashHex, out });
                if (missing == 0) {
                    break;
                }
            }
        }
    }
}

test "passGen actual" {
    var buf = [_]u8{'_'} ** 8;
    try passGen("ojvtpuvg", &buf);
    try testing.expectEqualSlices(u8, "1050cbbd", &buf);
}

//test "passGen sample" {
//    var buf = [_]u8{'_'} ** 8;
//    try passGen("abc", &buf);
//    try testing.expectEqualSlices(u8, "05ace8e3", &buf);
//}
