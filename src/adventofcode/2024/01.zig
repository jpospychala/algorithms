const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const a = gpa.allocator();

    const result = try distF("01.txt", a);
    std.debug.print("{d}\n", .{result});
}

fn distF(path: []const u8, a: std.mem.Allocator) !usize {
    var f = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer f.close();
    var l1 = std.ArrayList(isize).init(a);
    defer l1.deinit();
    var l2 = std.ArrayList(isize).init(a);
    defer l2.deinit();

    var buf_reader = std.io.bufferedReader(f.reader());
    var in_stream = buf_reader.reader();

    var buf = [_]u8{0} ** 1024;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const sep = "   ";
        if (std.mem.indexOf(u8, line, sep)) |space| {
            const l1num = try std.fmt.parseInt(isize, line[0..space], 10);
            const l2num = try std.fmt.parseInt(isize, line[space + sep.len .. line.len], 10);
            try l1.append(l1num);
            try l2.append(l2num);
        }
    }

    return distance(l1.items, l2.items);
}

fn distance(l1: []isize, l2: []isize) usize {
    var result: usize = 0;
    std.sort.block(isize, l1, {}, comptime std.sort.asc(isize));
    std.sort.block(isize, l2, {}, comptime std.sort.asc(isize));
    for (l1, l2) |i, j| {
        result += @abs(i - j);
    }
    return result;
}

test "sample" {
    const l1 = try std.testing.allocator.alloc(isize, 6);
    defer std.testing.allocator.free(l1);
    std.mem.copyForwards(isize, l1, &[_]isize{ 3, 4, 2, 1, 3, 3 });

    const l2 = try std.testing.allocator.alloc(isize, 6);
    defer std.testing.allocator.free(l2);
    std.mem.copyForwards(isize, l2, &[_]isize{ 4, 3, 5, 3, 9, 3 });

    try std.testing.expectEqual(11, distance(l1, l2));
}

test "file sample" {
    try std.testing.expectEqual(11, try distF("01.test.txt", std.testing.allocator));
}
