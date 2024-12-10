const std = @import("std");

pub fn main() !void {
    const path = "02.txt";
    const f = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer f.close();

    const count = try countSafeReports(f.reader());
    std.debug.print("{d}\n", .{count});
}

fn countSafeReports(reader: anytype) !usize {
    var result: usize = 0;

    var buf = [_]u8{0} ** 1024;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (try reportIsSafe(line)) {
            result += 1;
        }
    }
    return result;
}

fn reportIsSafe(line: []u8) !bool {
    var iter = std.mem.splitScalar(u8, line, ' ');
    var prevMaybe: ?isize = null;
    var signMaybe: ?isize = null;

    while (iter.next()) |lvlBuf| {
        const level = try std.fmt.parseInt(isize, lvlBuf, 10);
        if (prevMaybe) |prev| {
            const diff: isize = level - prev;
            const currSign = std.math.sign(diff);
            const absDiff = @abs(diff);
            if (absDiff >= 1 and absDiff <= 3) {
                if (signMaybe) |sign| {
                    if (sign != currSign) {
                        return false;
                    }
                } else {
                    signMaybe = currSign;
                }
            } else {
                return false;
            }
        }
        prevMaybe = level;
    }
    return true;
}

test {
    const input =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
        \\
    ;
    var fixedBuffer = std.io.fixedBufferStream(input);

    const actual = countSafeReports(fixedBuffer.reader());
    try std.testing.expectEqual(2, actual);
}
