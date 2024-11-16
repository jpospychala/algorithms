const std = @import("std");
const testing = std.testing;

const RectInstr = struct {
    w: usize,
    h: usize,
};

const RotateColInstr = struct {
    x: usize,
    shift: usize,
};

const RotateRowInstr = struct {
    y: usize,
    shift: usize,
};

const Instruction = union(enum) {
    rect: RectInstr,
    rotateCol: RotateColInstr,
    rotateRow: RotateRowInstr,
};

const ParseError = error{
    UnknownInstruction,
};

const Parser = struct {
    fn parse(line: []const u8) !Instruction {
        if (std.mem.startsWith(u8, line, "rect")) {
            return .{ .rect = try Parser.parseRect(line) };
        } else if (std.mem.startsWith(u8, line, "rotate row")) {
            return .{ .rotateRow = try Parser.parseRotateRow(line) };
        } else if (std.mem.startsWith(u8, line, "rotate column")) {
            return .{ .rotateCol = try Parser.parseRotateColumn(line) };
        } else return ParseError.UnknownInstruction;
    }

    // parses "rect WxH"
    fn parseRect(line: []const u8) !RectInstr {
        const xPos = std.mem.indexOfScalar(u8, line, 'x').?;
        const wStartPos = "rect ".len;
        const w = try std.fmt.parseUnsigned(usize, line[wStartPos..xPos], 10);
        const h = try std.fmt.parseUnsigned(usize, line[xPos + 1 ..], 10);
        return .{ .w = w, .h = h };
    }

    // rotate row y=A by B
    fn parseRotateRow(line: []const u8) !RotateRowInstr {
        const yStartOffset = "rotate row y=".len;
        const yEnd = std.mem.indexOfScalarPos(u8, line, yStartOffset, ' ').?;
        const shiftStart = std.mem.lastIndexOfScalar(u8, line, ' ').?;
        const y = try std.fmt.parseUnsigned(usize, line[yStartOffset..yEnd], 10);
        const shift = try std.fmt.parseUnsigned(usize, line[shiftStart + 1 ..], 10);
        return .{
            .y = y,
            .shift = shift,
        };
    }

    // rotate column y=A by B
    fn parseRotateColumn(line: []const u8) !RotateColInstr {
        const xStartOffset = "rotate column x=".len;
        const xEnd = std.mem.indexOfScalarPos(u8, line, xStartOffset, ' ').?;
        const shiftStart = std.mem.lastIndexOfScalar(u8, line, ' ').?;
        const x = try std.fmt.parseUnsigned(usize, line[xStartOffset..xEnd], 10);
        const shift = try std.fmt.parseUnsigned(usize, line[shiftStart + 1 ..], 10);
        return .{
            .x = x,
            .shift = shift,
        };
    }
};

const Board = struct {
    w: usize,
    h: usize,
    pixels: [][]u1,
    shiftbuf: []u1,
    allocator: std.mem.Allocator,

    fn init(w: usize, h: usize, allocator: std.mem.Allocator) !Board {
        const pixels = try allocator.alloc([]u1, w);
        for (pixels, 0..) |_, i| {
            pixels[i] = try allocator.alloc(u1, h);
        }
        const shiftbuf = try allocator.alloc(u1, @max(w, h));
        return .{
            .w = w,
            .h = h,
            .pixels = pixels,
            .shiftbuf = shiftbuf,
            .allocator = allocator,
        };
    }

    fn deinit(b: Board) void {
        for (b.pixels, 0..) |_, i| {
            b.allocator.free(b.pixels[i]);
        }
        b.allocator.free(b.pixels);
        b.allocator.free(b.shiftbuf);
    }

    fn print(b: Board, allocator: std.mem.Allocator) ![]u8 {
        var ret: []u8 = try allocator.alloc(u8, (b.w + 1) * b.h);
        for (0..b.h) |y| {
            for (0..b.w) |x| {
                ret[x + ((b.w + 1) * y)] = if (b.pixels[x][y] == 1) '#' else '.';
            }
            ret[b.w + b.w * y + y] = '\n';
        }
        return ret;
    }

    fn pixelsCount(b: Board) usize {
        var count: usize = 0;
        for (0..b.w) |x| {
            for (0..b.h) |y| {
                if (b.pixels[x][y] == 1) {
                    count += 1;
                }
            }
        }
        return count;
    }

    fn apply(b: Board, instr: Instruction) void {
        switch (instr) {
            .rect => |i| {
                for (0..@min(i.w, b.w)) |x| {
                    for (0..@min(i.h, b.h)) |y| {
                        b.pixels[x][y] = 1;
                    }
                }
            },
            .rotateCol => |i| {
                for (0..b.h) |y| {
                    b.shiftbuf[y] = b.pixels[i.x][(y + b.h - i.shift) % b.h];
                }
                for (0..b.h) |y| {
                    b.pixels[i.x][y] = b.shiftbuf[y];
                }
            },
            .rotateRow => |i| {
                for (0..b.w) |x| {
                    b.shiftbuf[x] = b.pixels[(x + b.w - i.shift) % b.w][i.y];
                }
                for (0..b.w) |x| {
                    b.pixels[x][i.y] = b.shiftbuf[x];
                }
            },
        }
    }
};

test "Parser.parseRect" {
    try testing.expectEqual(RectInstr{ .w = 10, .h = 20 }, Parser.parseRect("rect 10x20"));
}

test "Parser.rotateRotateColumn" {
    try testing.expectEqual(RotateColInstr{ .x = 11, .shift = 21 }, Parser.parseRotateColumn("rotate column x=11 by 21"));
}

test "Parser.rotateRow" {
    try testing.expectEqual(RotateRowInstr{ .y = 21, .shift = 32 }, Parser.parseRotateRow("rotate row y=21 by 32"));
}

test "board.applyRrect" {
    var b = try Board.init(7, 3, testing.allocator);
    defer b.deinit();
    b.apply(try Parser.parse("rect 3x2"));
    const buf = try b.print(testing.allocator);
    defer testing.allocator.free(buf);
    try testing.expectEqualStrings(
        \\###....
        \\###....
        \\.......
        \\
    , buf);
}

test "board.rotateRotateColumn" {
    var b = try Board.init(7, 3, testing.allocator);
    defer b.deinit();
    b.apply(try Parser.parse("rect 3x2"));
    b.apply(try Parser.parse("rotate column x=1 by 1"));
    b.apply(try Parser.parse("rotate row y=0 by 4"));
    b.apply(try Parser.parse("rotate column x=1 by 1"));
    const buf = try b.print(testing.allocator);
    defer testing.allocator.free(buf);
    try testing.expectEqualStrings(
        \\.#..#.#
        \\#.#....
        \\.#.....
        \\
    , buf);
    try testing.expectEqual(6, b.pixelsCount());
}

test "aoc2016_08 input" {
    var b = try Board.init(50, 6, testing.allocator);
    defer b.deinit();

    var file = try std.fs.cwd().openFile("aoc2016_08.txt", .{});
    defer file.close();

    const reader = file.reader();
    var buf = [_]u8{0} ** 4096;
    while (true) {
        const sliceResult = reader.readUntilDelimiter(&buf, '\n');
        if (sliceResult == error.EndOfStream) {
            break;
        }
        const slice = try sliceResult;
        std.debug.print("{s}\n", .{slice});
        b.apply(try Parser.parse(slice));
        const p = try b.print(testing.allocator);
        std.debug.print("{s} pixes: {d}\n", .{ p, b.pixelsCount() });
        testing.allocator.free(p);
    }
    try testing.expectEqual(100, b.pixelsCount());
}
