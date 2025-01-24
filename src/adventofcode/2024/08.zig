const std = @import("std");

const Point = struct {
    x: usize,
    y: usize,
};

const Map = struct {
    buf: []u8,
    w: usize,
    h: usize,

    fn init(buf: []const u8, a: std.mem.Allocator) !Map {
        const w = std.mem.indexOfScalar(u8, buf, '\n').?;
        const h = buf.len / w;

        const copy = try a.alloc(u8, buf.len);
        @memcpy(copy, buf);
        return .{
            .buf = copy,
            .w = w,
            .h = h,
        };
    }

    fn deinit(map: Map, a: std.mem.Allocator) void {
        a.free(map.buf);
    }

    fn toOffset(map: Map, point: Point) usize {
        return point.y * (map.w + 1) + point.x;
    }

    fn toPoint(map: Map, idx: usize) Point {
        return .{
            .x = @mod(idx, (map.w + 1)),
            .y = idx / (map.w + 1),
        };
    }

    fn mkPoint(map: Map, x: isize, y: isize) ?Point {
        if (x >= 0 and x < map.w and y >= 0 and y < map.h) {
            return Point{
                .x = @intCast(x),
                .y = @intCast(y),
            };
        }
        return null;
    }
};

fn toIsize(a: usize) isize {
    return @as(isize, @intCast(a));
}

//pt1-pt2+pt1   pt1-    pt2     +(pt2-pt1)
//pt2+(pt2-pt1)   pt2-    pt1     pt1+(-pt2+pt1)
fn antinodes(buf: []const u8, a: std.mem.Allocator) !usize {
    const map = try Map.init(buf, a);
    defer map.deinit(a);
    var list = std.ArrayList(usize).init(a);
    defer list.deinit();

    for (map.buf, 0..) |a1, idx1| {
        if (a1 != '.' and a1 != '#') {
            const pt1 = map.toPoint(idx1);
            for (map.buf, 0..) |a2, idx2| {
                if (a2 == a1 and idx2 != idx1) {
                    // found two different antennas of same type
                    const pt2 = map.toPoint(idx2);
                    if (map.mkPoint(
                        toIsize(pt1.x) - toIsize(pt2.x) + toIsize(pt1.x),
                        toIsize(pt1.y) - toIsize(pt2.y) + toIsize(pt1.y),
                    )) |pk| {
                        const offs = map.toOffset(pk);
                        _ = std.mem.indexOfScalar(usize, list.items, offs) orelse {
                            if (map.buf[offs] == '.') {
                                //      map.buf[offs] = '#';
                            }
                            try list.append(offs);
                        };
                    }
                    if (map.mkPoint(
                        toIsize(pt2.x) + toIsize(pt2.x) - toIsize(pt1.x),
                        toIsize(pt2.y) + toIsize(pt2.y) - toIsize(pt1.y),
                    )) |pk| {
                        const offs = map.toOffset(pk);
                        _ = std.mem.indexOfScalar(usize, list.items, offs) orelse {
                            if (map.buf[offs] == '.') {
                                //       map.buf[offs] = '#';
                            }
                            try list.append(offs);
                        };
                    }
                }
            }
        }
    }

    std.debug.print("Debug:\n{s}\n", .{map.buf});
    return list.items.len;
}

fn findAntennas(map: Map, a: std.mem.Allocator) ![]usize {
    var list = std.ArrayList(Point).init(a);
    for (map.buf, 0..) |c, idx| {
        if (c != '.') {
            list.append(idx);
        }
    }
    return try list.toOwnedSlice();
}

test "8 part one" {
    const actual = try antinodes(testInput(), std.testing.allocator);
    try std.testing.expectEqual(14, actual);
}

test "8 part one final" {
    const actual = try antinodes(finalInput(), std.testing.allocator);
    try std.testing.expectEqual(256, actual);
}

test "antinodes 1" {
    const in =
        \\.......
        \\....a..
        \\..a....
        \\.......
    ;
    const actual = try antinodes(in, std.testing.allocator);
    try std.testing.expectEqual(2, actual);
}

test "antinodes 2" {
    const in =
        \\.......
        \\..a....
        \\....a..
        \\.......
    ;
    const actual = try antinodes(in, std.testing.allocator);
    try std.testing.expectEqual(2, actual);
}

test "antinodes 3" {
    const in =
        \\.......
        \\..a....
        \\..a....
        \\.......
    ;
    const actual = try antinodes(in, std.testing.allocator);
    try std.testing.expectEqual(2, actual);
}

test "antinodes 4" {
    const in =
        \\.......
        \\..aa...
        \\.......
    ;
    const actual = try antinodes(in, std.testing.allocator);
    try std.testing.expectEqual(2, actual);
}

test "test offset" {
    const in = input0();
    const map = try Map.init(in, std.testing.allocator);
    defer map.deinit(std.testing.allocator);
    try std.testing.expectEqual(std.mem.indexOfScalar(u8, in, '1'), map.toOffset(Point{ .x = 0, .y = 0 }));
    try std.testing.expectEqual(std.mem.indexOfScalar(u8, in, '2'), map.toOffset(Point{ .x = 11, .y = 0 }));
    try std.testing.expectEqual(std.mem.indexOfScalar(u8, in, '3'), map.toOffset(Point{ .x = 0, .y = 11 }));
    try std.testing.expectEqual(std.mem.indexOfScalar(u8, in, '4'), map.toOffset(Point{ .x = 11, .y = 11 }));
}

fn input0() []const u8 {
    return 
    \\1..........2
    \\........0...
    \\.....0......
    \\.......0....
    \\....0.......
    \\......A.....
    \\............
    \\............
    \\........A...
    \\.........A..
    \\............
    \\3..........4
    ;
}

fn testInput() []const u8 {
    return 
    \\............
    \\........0...
    \\.....0......
    \\.......0....
    \\....0.......
    \\......A.....
    \\............
    \\............
    \\........A...
    \\.........A..
    \\............
    \\............
    ;
}

fn finalInput() []const u8 {
    return 
    \\....h.....Q..............Y........................
    \\...............................Y........C.........
    \\...............m..........x................B......
    \\........................Y..............qB.........
    \\......g4.........................h..Y.....q...c...
    \\................n.....R...........................
    \\.......................................w........5.
    \\........g...m...........................w5........
    \\..n...........R.1................W.......q.5......
    \\.........h...n.................e..................
    \\...............................R..........B....C..
    \\.........4................................5.e.....
    \\.......0..4......n.......x..w.....................
    \\.......g.....m........x..b.....W.....B.......w....
    \\..............m........................3......C...
    \\........q...0.......h....................C.3......
    \\..................3.....................D.........
    \\...............R..........3.............X.........
    \\..............................W............k2.....
    \\..........7............................2..........
    \\...............A.............................X...2
    \\.......................c...x......................
    \\....................................d.............
    \\.....1......................d.....................
    \\...........1...........................e..........
    \\.........0.7K.........................2.........W.
    \\...b......0.....A.................................
    \\......................1....ic.....................
    \\......b......................i....................
    \\..Q.....b..........................A..E...........
    \\...7.........................V....................
    \\........A.....................v......d............
    \\........v............c...................8E.......
    \\..............................V........8.....E..N.
    \\......................6...........................
    \\.......I....M....................V................
    \\...G......................a.......8...............
    \\.........r.9........a...i..................X......
    \\...............r..i...............e............N..
    \\.....H...........k....9.....6...............8.....
    \\.v.....................6................V.........
    \\.........v.......a........k..........D............
    \\Ha..........k.........K........E.......d..........
    \\...............y.MG..............6....D...........
    \\.........H..G...M......9.K..............N.........
    \\.......G.........................K................
    \\...............M.........I.......D................
    \\..................................................
    \\....r....y................9.......................
    \\....y................................N............
    ;
}
