const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const a = gpa.allocator();

    const result = try distF("01.txt", a);
    std.debug.print("{d}\n", .{result});
}

fn distF(path: []const u8, a: std.mem.Allocator) !isize {
    var f = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer f.close();
    var l1 = std.ArrayList(isize).init(a);
    defer l1.deinit();
    var l2 = std.AutoHashMap(isize, isize).init(a);
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
            const entry = try l2.getOrPut(l2num);
            entry.value_ptr.* = if (entry.found_existing) entry.value_ptr.* + 1 else 1;
        }
    }

    return distance(l1.items, l2);
}

fn distance(l1: []isize, l2: std.AutoHashMap(isize, isize)) isize {
    var result: isize = 0;
    for (l1) |i| {
        if (l2.get(i)) |count| {
            result += i * count;
        }
    }
    return result;
}

test "file sample" {
    try std.testing.expectEqual(31, try distF("01.test.txt", std.testing.allocator));
}
