const std = @import("std");
const testing = std.testing;

const Stat = struct {
    counts: [26]u8 = [_]u8{0} ** 26,
    max: u8 = 0,

    fn inc(s: *Stat, c: u8) void {
        s.counts[c] += 1;
        if (s.counts[c] > s.counts[s.max]) {
            s.max = c;
        }
    }

    fn minimum(s: Stat) u8 {
        var min = s.max;
        for (s.counts, 0..) |count, i| {
            if (count < s.counts[min] and count > 0) {
                min = @intCast(i);
            }
        }
        return min;
    }
};

fn aoc2016_05(buf: []const u8) void {
    const len = 8;
    var stats = [_]Stat{.{}} ** len;

    var col: usize = 0;
    for (buf) |c| {
        if (c == '\n') {
            col = 0;
            continue;
        }
        stats[col].inc(c - 'a');
        col += 1;
    }

    var answer = [_]u8{0} ** len;
    for (stats, 0..) |stat, i| {
        answer[i] = stat.max + 'a';
    }
    std.debug.print("{s}\n", .{answer});
}

fn aoc2016_05b(buf: []const u8) void {
    const len = 8;
    var stats = [_]Stat{.{}} ** len;

    var col: usize = 0;
    for (buf) |c| {
        if (c == '\n') {
            col = 0;
            continue;
        }
        stats[col].inc(c - 'a');
        col += 1;
    }

    var answer = [_]u8{0} ** len;
    for (stats, 0..) |stat, i| {
        answer[i] = stat.minimum() + 'a';
    }
    std.debug.print("{s}\n", .{answer});
}

test "actual task a" {
    var file = try std.fs.cwd().openFile("aoc2016_06.txt", .{});
    defer file.close();

    const input = try file.readToEndAlloc(testing.allocator, 1024 * 1024);
    defer testing.allocator.free(input);
    aoc2016_05(input);
}

test "actual task b" {
    var file = try std.fs.cwd().openFile("aoc2016_06.txt", .{});
    defer file.close();

    const input = try file.readToEndAlloc(testing.allocator, 1024 * 1024);
    defer testing.allocator.free(input);
    aoc2016_05b(input);
}

test "sample case a" {
    const input =
        \\eedadn
        \\drvtee
        \\eandsr
        \\raavrd
        \\atevrs
        \\tsrnev
        \\sdttsa
        \\rasrtv
        \\nssdts
        \\ntnada
        \\svetve
        \\tesnvt
        \\vntsnd
        \\vrdear
        \\dvrsen
        \\enarar
    ;
    aoc2016_05(input);
}

test "sample case b" {
    const input =
        \\eedadn
        \\drvtee
        \\eandsr
        \\raavrd
        \\atevrs
        \\tsrnev
        \\sdttsa
        \\rasrtv
        \\nssdts
        \\ntnada
        \\svetve
        \\tesnvt
        \\vntsnd
        \\vrdear
        \\dvrsen
        \\enarar
    ;
    aoc2016_05b(input);
}
