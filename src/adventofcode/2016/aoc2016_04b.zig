const std = @import("std");
const testing = std.testing;

const RoomName = struct {
    sectorId: usize,
    isValid: bool,
    nameAndId: []const u8,

    fn init(buf: []const u8) !RoomName {
        const buftrim = std.mem.trimRight(u8, buf, &[_]u8{ 0, 10 });
        var iter = std.mem.tokenizeScalar(u8, buftrim, '[');
        const nameAndId = iter.next().?;
        const checkSum: []const u8 = iter.next().?;
        var sectorId: usize = 0;
        var letterCounts = [_]u8{0} ** 26;
        var max: usize = 0;

        for (nameAndId) |c| {
            if (c >= 'a' and c <= 'z') {
                letterCounts[c - 'a'] += 1;
                if (letterCounts[c - 'a'] > max) {
                    max = letterCounts[c - 'a'];
                }
            } else if (c >= '0' and c <= '9') {
                sectorId = sectorId * 10 + (c - '0');
            }
        }

        var isValid = true;
        for (checkSum[0..4], 0..4) |c, i| {
            if ((i == 0) and (letterCounts[c - 'a'] != max)) {
                isValid = false;
                break;
            }
            if (i > 0 and letterCounts[c - 'a'] > max) {
                isValid = false;
                break;
            }
            max = letterCounts[c - 'a'];
            letterCounts[c - 'a'] = 0;
        }
        for (0..letterCounts.len - 1) |i| {
            if (letterCounts[i] > max) {
                isValid = false;
                break;
            }
        }

        return RoomName{
            .sectorId = sectorId,
            .isValid = isValid,
            .nameAndId = nameAndId,
        };
    }

    fn decrypt(rn: RoomName, buf: []u8) void {
        for (rn.nameAndId, 0..) |c, i| {
            if (c == '-') {
                buf[i] = ' ';
            } else {
                const newc: usize = rn.sectorId + c - 'a';
                buf[i] = @intCast(@mod(newc, 26) + 'a');
            }
        }
    }
};

fn aoc2016_04() !void {
    var allocator = testing.allocator;

    var file = try std.fs.cwd().openFile("aoc2016_04.txt", .{});
    defer file.close();

    const reader = file.reader();
    var buf = [_]u8{0} ** 1024;
    while ((reader.readUntilDelimiter(&buf, '\n')) != error.EndOfStream) {
        const rn = try RoomName.init(&buf);
        if (rn.isValid) {
            const decrypted: []u8 = try allocator.alloc(u8, rn.nameAndId.len);
            defer allocator.free(decrypted);
            rn.decrypt(decrypted);
            if (std.mem.indexOf(u8, decrypted, "northpole") != null) {
                std.debug.print("{d} {s}\n", .{ rn.sectorId, decrypted });
            }
        }
    }
}

test "run" {
    try aoc2016_04();
}
