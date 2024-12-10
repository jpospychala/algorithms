const std = @import("std");

pub fn main() !void {
    const path = "02.txt";
    const f = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer f.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const a = gpa.allocator();
    defer _ = gpa.deinit();

    const count = try countSafeReports(f.reader(), a);
    std.debug.print("{d}\n", .{count});
}

fn countSafeReports(reader: anytype, a: std.mem.Allocator) !usize {
    var result: usize = 0;

    var buf = [_]u8{0} ** 1024;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const nums = try toNums(line, a);
        for (0..nums.len) |i| {
            if (try reportIsSafe(nums, i)) {
                result += 1;
                break;
            }
        }
    }
    return result;
}

fn toNums(line: []u8, a: std.mem.Allocator) ![]isize {
    var iter = std.mem.splitScalar(u8, line, ' ');
    var nums = std.ArrayList(isize).init(a);
    while (iter.next()) |lvlBuf| {
        const level = try std.fmt.parseInt(isize, lvlBuf, 10);
        try nums.append(level);
    }
    return try nums.toOwnedSlice();
}

fn reportIsSafe(nums: []isize, skip: usize) !bool {
    var prevMaybe: ?isize = null;
    var signMaybe: ?isize = null;

    for (nums, 0..nums.len) |level, i| {
        if (i == skip) {
            continue;
        }
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

    const actual = countSafeReports(fixedBuffer.reader(), std.testing.allocator);
    try std.testing.expectEqual(4, actual);
}
