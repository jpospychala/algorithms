const std = @import("std");
const testing = std.testing;

fn isTriangle(a: usize, b: usize, c: usize) bool {
    return a + b > c and b + c > a and a + c > b;
}

fn aoc2016_03() !void {
    var file = try std.fs.cwd().openFile("aoc2016_03.txt", .{});
    defer file.close();

    const reader = file.reader();
    var buf = [_]u8{0} ** 1024;
    var triangleCount: usize = 0;
    while ((reader.readUntilDelimiter(&buf, '\n')) != error.EndOfStream) {
        const buftrim = std.mem.trimRight(u8, &buf, &[_]u8{ 0, 10 });
        var iter = std.mem.tokenizeScalar(u8, buftrim, ' ');
        const a = try std.fmt.parseInt(usize, iter.next().?, 10);
        const b = try std.fmt.parseInt(usize, iter.next().?, 10);
        const c = try std.fmt.parseInt(usize, iter.next().?, 10);
        if (isTriangle(a, b, c)) {
            triangleCount += 1;
        }
    }
    std.debug.print("triangleCount {d}\n", .{triangleCount});
}

test "run" {
    try aoc2016_03();
}
