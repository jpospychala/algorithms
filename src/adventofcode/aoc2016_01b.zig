const std = @import("std");
const testing = std.testing;

const Token = struct {
    dir: i4 = 0, // -1 Left, 1 Right
    dist: isize = 0,
    pos: usize = 0,

    fn next(token: *Token, s: []const u8) !bool {
        if (token.pos >= s.len) {
            return false;
        }

        const separatorPos = std.mem.indexOfPos(u8, s, token.pos, ", ");
        const tokEnd = separatorPos orelse s.len;
        token.dir = if (s[token.pos] == 'L') -1 else 1;
        token.dist = try std.fmt.parseInt(isize, s[token.pos + 1 .. tokEnd], 10);
        token.pos = if (separatorPos == null) s.len else separatorPos.? + 2;
        return true;
    }
};

const Point = [2]isize;

const Path = struct {
    points: [100]Point,
    count: usize = 0,

    fn addPoint(p: *Path, point: Point) void {
        p.points[p.count] = point;
        p.count += 1;
    }

    fn intersects(p: *Path, point: Point) ?usize {
        const p3 = p.points[p.count - 1];
        if (p.count < 2) {
            return null;
        }
        for (p.points[0 .. p.count - 2], p.points[1 .. p.count - 1]) |p1, p2| {
            const i = Path.intersection(p1, p2, p3, point);
            if (i != null) {
                return i;
            }
        }
        return null;
    }

    fn intersection(p1: Point, p2: Point, p3: Point, p4: Point) ?usize {
        for (0..2) |axis| {
            const axis2 = @mod(axis + 1, 2);
            // is perpendicular
            if (p1[axis] == p2[axis] and p3[axis2] == p4[axis2]) {
                if (@min(p1[axis2], p2[axis2]) <= p3[axis2] and p3[axis2] <= @max(p1[axis2], p2[axis2]) and
                    @min(p3[axis], p4[axis]) <= p1[axis] and p1[axis] <= @max(p3[axis], p4[axis]))
                {
                    return @abs(p1[axis]) + @abs(p3[axis2]);
                }
            }

            // is parallel
            if ((p1[axis] == p2[axis]) and (p2[axis] == p3[axis]) and (p3[axis] == p4[axis])) {
                const minp1p2: isize = @min(p1[axis2], p2[axis2]);
                const minp3p4: isize = @min(p3[axis2], p4[axis2]);

                if (minp1p2 <= minp3p4 and minp3p4 <= @max(p1[axis2], p2[axis2])) {
                    return @abs(minp1p2) + @abs(minp3p4);
                }
            }
        }

        return null;
    }
};

fn aoc2016_01b(s: []const u8) !?usize {
    var path = Path{ .points = [_]Point{Point{ 0, 0 }} ** 100 };
    path.addPoint(Point{ 0, 0 });

    var dir: isize = 0; // 0-North, 1-East, 2-South, 3-West
    var token: Token = Token{};

    while (try token.next(s)) {
        dir = @mod(dir + token.dir, 4);
        const northeast: isize = (if (dir < 2) 1 else -1);
        const move: isize = northeast * token.dist;

        const lastpt = path.points[path.count - 1];
        var next = Point{ lastpt[0], lastpt[1] };
        next[@abs(@mod(dir, 2))] += move;

        const intersect = path.intersects(next);
        if (intersect != null) {
            return intersect;
        }
        path.addPoint(next);
    }
    return null;
}

test "intersect" {
    try testing.expectEqual(0, Path.intersection(Point{ 0, 0 }, Point{ 0, 10 }, Point{ 0, 0 }, Point{ 0, 10 }));
    try testing.expectEqual(0, Path.intersection(Point{ 0, 0 }, Point{ 0, 10 }, Point{ 0, 0 }, Point{ 10, 0 }));
    try testing.expectEqual(0, Path.intersection(Point{ 0, 0 }, Point{ 0, 10 }, Point{ 10, 0 }, Point{ 0, 0 }));
    try testing.expectEqual(null, Path.intersection(Point{ 0, 0 }, Point{ 0, 10 }, Point{ -1, 9 }, Point{ -2, 9 }));
    try testing.expectEqual(1, Path.intersection(Point{ 0, 0 }, Point{ 0, -2 }, Point{ -1, -1 }, Point{ 0, -1 }));
    try testing.expectEqual(6, Path.intersection(Point{ 0, 1 }, Point{ 10, 1 }, Point{ 5, 6 }, Point{ 5, -4 }));
}

test "passing cases" {
    try testing.expectEqual(null, aoc2016_01b("R2, L3"));
    try testing.expectEqual(0, aoc2016_01b("R2, R2, R2, R2"));
    try testing.expectEqual(1, aoc2016_01b("R2, R1, R1, R1"));
    try testing.expectEqual(1, aoc2016_01b("L2, L1, L1, L1"));
    try testing.expectEqual(9, aoc2016_01b("R10, R1, R1, R1"));
    try testing.expectEqual(11, aoc2016_01b("R10, R1, R1, L1, L1, L1"));
}

test "failing cases" {
    try testing.expectEqual(147, aoc2016_01b("R5, R4, R2, L3, R1, R1, L4, L5, R3, L1, L1, R4, L2, R1, R4, R4, L2, L2, R4, L4, R1, R3, L3, L1, L2, R1, R5, L5, L1, L1, R3, R5, L1, R4, L5, R5, R1, L185, R4, L1, R51, R3, L2, R78, R1, L4, R188, R1, L5, R5, R2, R3, L5, R3, R4, L1, R2, R2, L4, L4, L5, R5, R4, L4, R2, L5, R2, L1, L4, R4, L4, R2, L3, L4, R2, L3, R3, R2, L2, L3, R4, R3, R1, L4, L2, L5, R4, R4, L1, R1, L5, L1, R3, R1, L2, R1, R1, R3, L4, L1, L3, R2, R4, R2, L2, R1, L5, R3, L3, R3, L1, R4, L3, L3, R4, L2, L1, L3, R2, R3, L2, L1, R4, L3, L5, L2, L4, R1, L4, L4, R3, R5, L4, L1, L1, R4, L2, R5, R1, R1, R2, R1, R5, L1, L3, L5, R2"));
}
