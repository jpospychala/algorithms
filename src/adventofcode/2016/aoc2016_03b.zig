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
    var triangles = [_][3]usize{[_]usize{ 0, 0, 0 }} ** 3;
    wlabel: while (true) {
        for (0..3) |i| {
            if (reader.readUntilDelimiter(&buf, '\n') == error.EndOfStream) {
                break :wlabel;
            }
            const buftrim = std.mem.trimRight(u8, &buf, &[_]u8{ 0, 10 });
            var iter = std.mem.tokenizeScalar(u8, buftrim, ' ');
            triangles[0][i] = try std.fmt.parseInt(usize, iter.next().?, 10);
            triangles[1][i] = try std.fmt.parseInt(usize, iter.next().?, 10);
            triangles[2][i] = try std.fmt.parseInt(usize, iter.next().?, 10);
        }
        for (0..3) |i| {
            if (isTriangle(triangles[i][0], triangles[i][1], triangles[i][2])) {
                triangleCount += 1;
            }
        }
    }
    std.debug.print("triangleCount {d}\n", .{triangleCount});
}

test "run" {
    try aoc2016_03();
}
