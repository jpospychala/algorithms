// https://leetcode.com/problems/construct-quad-tree/description/?envType=study-plan-v2&envId=top-interview-150

const std = @import("std");

const QuadTree = struct {
    val: bool,
    isLeaf: bool,
    tl: ?*QuadTree, // top-left
    tr: ?*QuadTree, // top-right
    bl: ?*QuadTree, // bottom-left
    br: ?*QuadTree, // bottom-right

    fn init(input: []const []const bool, a: std.mem.Allocator) !*QuadTree {
        return QuadTree.init_xy(input, 0, 0, input.len, a);
    }

    fn init_xy(input: []const []const bool, x: usize, y: usize, n: usize, a: std.mem.Allocator) !*QuadTree {
        var qt = try a.create(QuadTree);
        qt.tl = null;
        qt.tr = null;
        qt.bl = null;
        qt.br = null;
        const v = input[x][y];
        qt.val = v;
        qt.isLeaf = true;
        if (n == 1) {
            return qt;
        }
        setValue: for (0..n) |xi| {
            for (0..n) |yi| {
                if (input[x + xi][y + yi] != v) {
                    qt.isLeaf = false;
                    break :setValue;
                }
            }
        }
        if (!qt.isLeaf) {
            qt.tl = try QuadTree.init_xy(input, x, y, n / 2, a);
            qt.tr = try QuadTree.init_xy(input, x + n / 2, y, n / 2, a);
            qt.bl = try QuadTree.init_xy(input, x, y + n / 2, n / 2, a);
            qt.br = try QuadTree.init_xy(input, x + n / 2, y + n / 2, n / 2, a);
        }
        return qt;
    }

    fn deinit(qt: *QuadTree, a: std.mem.Allocator) void {
        if (!qt.isLeaf) {
            qt.tl.?.deinit(a);
            qt.tr.?.deinit(a);
            qt.bl.?.deinit(a);
            qt.br.?.deinit(a);
        }
        a.destroy(qt);
    }

    fn depth(qt: *QuadTree) usize {
        if (qt.isLeaf) {
            return 1;
        } else {
            return @max(qt.tl.?.depth(), @max(qt.tr.?.depth(), @max(qt.bl.?.depth(), qt.br.?.depth()))) + 1;
        }
    }

    fn print(qt: *QuadTree, a: std.mem.Allocator) ![]u8 {
        const w = (qt.depth() - 1) * 2;
        const result = try a.alloc(u8, (w + 1) * w);
        var buf = try a.alloc([]u8, w);
        for (0..w) |i| {
            buf[i] = result[i * (w + 1) .. (i * (w + 1) + w)];
        }
        qt.print_xy(buf, 0, 0, w);
        for (0..w) |i| {
            result[i * (w + 1) + w] = '\n';
        }
        a.free(buf);
        return result;
    }

    fn print_xy(qt: *QuadTree, buf: [][]u8, x: usize, y: usize, n: usize) void {
        if (qt.isLeaf) {
            const v: u8 = if (qt.val) '1' else '0';
            for (0..n) |xi| {
                for (0..n) |yi| {
                    buf[x + xi][y + yi] = v;
                }
            }
        } else {
            qt.tl.?.print_xy(buf, x, y, n / 2);
            qt.tr.?.print_xy(buf, x + n / 2, y, n / 2);
            qt.bl.?.print_xy(buf, x, y + n / 2, n / 2);
            qt.br.?.print_xy(buf, x + n / 2, y + n / 2, n / 2);
        }
    }
};

test "1" {
    const input = [_][]bool{
        @constCast(&[_]bool{ false, true }),
        @constCast(&[_]bool{ true, false }),
    };

    var qt = try QuadTree.init(&input, std.testing.allocator);
    defer qt.deinit(std.testing.allocator);
    const str = try qt.print(std.testing.allocator);
    defer std.testing.allocator.free(str);

    const expected =
        \\01
        \\10
        \\
    ;

    try std.testing.expectEqualStrings(expected, str);
}

test "2" {
    const input = [_][]bool{
        @constCast(&[_]bool{ false, false, true, true }),
        @constCast(&[_]bool{ false, false, true, true }),
        @constCast(&[_]bool{ true, true, false, false }),
        @constCast(&[_]bool{ true, true, false, false }),
    };

    var qt = try QuadTree.init(&input, std.testing.allocator);
    defer qt.deinit(std.testing.allocator);
    const str = try qt.print(std.testing.allocator);
    defer std.testing.allocator.free(str);

    const expected =
        \\01
        \\10
        \\
    ;

    try std.testing.expectEqualStrings(expected, str);
}

test "3" {
    const input = [_][]bool{
        @constCast(&[_]bool{ false, false, true, false }),
        @constCast(&[_]bool{ false, false, false, true }),
        @constCast(&[_]bool{ true, true, false, false }),
        @constCast(&[_]bool{ true, true, false, false }),
    };

    var qt = try QuadTree.init(&input, std.testing.allocator);
    defer qt.deinit(std.testing.allocator);
    const str = try qt.print(std.testing.allocator);
    defer std.testing.allocator.free(str);

    const expected =
        \\0010
        \\0001
        \\1100
        \\1100
        \\
    ;

    try std.testing.expectEqualStrings(expected, str);
}
