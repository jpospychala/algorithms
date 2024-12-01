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

fn aoc2016_01(s: []const u8) !usize {
    var dist: [2]isize = [2]isize{ 0, 0 }; // 0-NorthSouth, 1-EastWest
    var dir: isize = 0; // 0-North, 1-East, 2-South, 3-West
    var token: Token = Token{};

    while (try token.next(s)) {
        dir = @mod(dir + token.dir, 4);
        const northeast: isize = (if (dir < 2) 1 else -1);
        const move: isize = northeast * token.dist;
        dist[@abs(@mod(dir, 2))] += move;
        //  std.debug.print("\n{} {}.{} {} {}\n", .{ dir, dist[0], dist[1], idx, move });
    }
    return @abs(dist[0]) + @abs(dist[1]);
}

test "nextToken" {
    var tok = Token{};
    var result = tok.next("L1");
    try testing.expectEqual(true, result);
    try testing.expectEqual(Token{ .dir = -1, .dist = 1, .pos = 2 }, tok);

    tok = Token{};
    result = tok.next("R2, L3");
    try testing.expectEqual(true, result);
    try testing.expectEqual(Token{ .dir = 1, .dist = 2, .pos = 4 }, tok);

    tok = Token{};
    result = tok.next("L10, L2");
    try testing.expectEqual(true, result);
    try testing.expectEqual(Token{ .dir = -1, .dist = 10, .pos = 5 }, tok);

    result = tok.next("L10, L2");
    try testing.expectEqual(true, result);
    try testing.expectEqual(Token{ .dir = -1, .dist = 2, .pos = 7 }, tok);

    tok = Token{};
    result = tok.next("");
    try testing.expectEqual(false, result);
    try testing.expectEqual(Token{ .dir = 0, .dist = 0, .pos = 0 }, tok);
}

test "sample cases" {
    try testing.expectEqual(5, aoc2016_01("R2, L3"));
    try testing.expectEqual(2, aoc2016_01("R2, R2, R2"));
    try testing.expectEqual(12, aoc2016_01("R5, L5, R5, R3"));
    try testing.expectEqual(0, aoc2016_01("L1, L1, L1, L1, L1, L1, L1, L1"));
    try testing.expectEqual(0, aoc2016_01("R10, R10, R10, R10, R10, R10, R10, R10"));
    try testing.expectEqual(0, aoc2016_01("L100, L0, L100"));
    try testing.expectEqual(2, aoc2016_01("L1, R1"));
    try testing.expectEqual(231, aoc2016_01("R5, R4, R2, L3, R1, R1, L4, L5, R3, L1, L1, R4, L2, R1, R4, R4, L2, L2, R4, L4, R1, R3, L3, L1, L2, R1, R5, L5, L1, L1, R3, R5, L1, R4, L5, R5, R1, L185, R4, L1, R51, R3, L2, R78, R1, L4, R188, R1, L5, R5, R2, R3, L5, R3, R4, L1, R2, R2, L4, L4, L5, R5, R4, L4, R2, L5, R2, L1, L4, R4, L4, R2, L3, L4, R2, L3, R3, R2, L2, L3, R4, R3, R1, L4, L2, L5, R4, R4, L1, R1, L5, L1, R3, R1, L2, R1, R1, R3, L4, L1, L3, R2, R4, R2, L2, R1, L5, R3, L3, R3, L1, R4, L3, L3, R4, L2, L1, L3, R2, R3, L2, L1, R4, L3, L5, L2, L4, R1, L4, L4, R3, R5, L4, L1, L1, R4, L2, R5, R1, R1, R2, R1, R5, L1, L3, L5, R2"));
}
