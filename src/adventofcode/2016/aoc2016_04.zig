const std = @import("std");
const testing = std.testing;

const RoomName = struct {
    sectorId: usize,
    isValid: bool,

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
        };
    }
};

fn aoc2016_04() !void {
    var file = try std.fs.cwd().openFile("aoc2016_04.txt", .{});
    defer file.close();

    const reader = file.reader();
    var buf = [_]u8{0} ** 1024;
    var sectorIdSum: usize = 0;
    while ((reader.readUntilDelimiter(&buf, '\n')) != error.EndOfStream) {
        const rn = try RoomName.init(&buf);
        if (rn.isValid) {
            sectorIdSum += rn.sectorId;
        }
    }
    std.debug.print("sectorIdSum {d}\n", .{sectorIdSum});
}

test "run" {
    try aoc2016_04(); // 361724
}

test "sectorId" {
    try testing.expectEqual(1234, (try RoomName.init("a-b-c-d1234[abcd]"[0..])).sectorId);
}

test "isValid" {
    try testing.expectEqual(true, (try RoomName.init("aaaaa-bbb-z-y-x-123[abxyz]"[0..])).isValid);
    try testing.expectEqual(true, (try RoomName.init("a-b-c-d-e-f-g-h-987[abcde]"[0..])).isValid);
    try testing.expectEqual(true, (try RoomName.init("not-a-real-room-404[oarel]"[0..])).isValid);
    try testing.expectEqual(false, (try RoomName.init("totally-real-room-200[decoy]"[0..])).isValid);
}
