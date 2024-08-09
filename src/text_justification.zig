// Given an array of strings words and a width maxWidth, format the text such that each line has exactly maxWidth characters and is fully (left and right) justified.
// You should pack your words in a greedy approach; that is, pack as many words as you can in each line. Pad extra spaces ' ' when necessary so that each line has exactly maxWidth characters.
// Extra spaces between words should be distributed as evenly as possible. If the number of spaces on a line does not divide evenly between words, the empty slots on the left will be assigned more spaces than the slots on the right.
// For the last line of text, it should be left-justified, and no extra space is inserted between words.

const std = @import("std");

fn fullJustify(words: []const []const u8, maxWidth: usize, allocator: std.mem.Allocator) ![][]u8 {
    // go over words, count their lengths, add mandatory single space between words until all words for single
    // line are collected. Then take those words, calculate available spaces and place words evenly so that
    // spaces between words are of equal size.

    if (words.len == 0) {
        return &.{};
    }

    var result = std.ArrayList([]u8).init(allocator);

    var fromWord: usize = 0;
    var wordsLen: usize = 0;
    for (words, 0..) |word, i| {
        if (wordsLen + word.len + (i - fromWord) > maxWidth) {
            const line = try mkLine(words[fromWord..i], maxWidth, allocator);
            try result.append(line);
            wordsLen = 0;
            fromWord = i;
        }

        wordsLen += word.len;
    }
    if (fromWord <= words.len - 1) {
        const line = try mkLine(words[fromWord..words.len], maxWidth, allocator);
        try result.append(line);
    }
    return try result.toOwnedSlice();
}

fn mkLine(words: []const []const u8, maxWidth: usize, allocator: std.mem.Allocator) ![]u8 {
    var line = try allocator.alloc(u8, maxWidth);
    @memset(line, ' ');

    var wordsLen: usize = 0;
    for (words) |w| {
        wordsLen += w.len;
    }

    var spacesToSplit = maxWidth - wordsLen;
    var sepCount = words.len - 1;
    var offset: usize = 0;
    for (words) |w| {
        std.mem.copyForwards(u8, line[offset .. offset + w.len], w);
        offset += w.len;
        if (sepCount > 0) {
            const spaces = try std.math.divCeil(usize, spacesToSplit, sepCount);
            spacesToSplit -= spaces;
            sepCount -= 1;
            offset += spaces;
        }
    }

    return line;
}

test "justify width 1" {
    const words: []const []const u8 = &.{"a"};
    const expected: []const []const u8 = &.{"a"};

    const actual = try fullJustify(words, 1, std.testing.allocator);
    defer deinitDeep(actual, std.testing.allocator);

    try std.testing.expectEqualDeep(expected, actual);
}

test "justify width 5" {
    const words: []const []const u8 = &.{ "a", "brown", "fox", "jumps" };
    const expected: []const []const u8 = &.{
        "a    ",
        "brown",
        "fox  ",
        "jumps",
    };

    const actual = try fullJustify(words, 5, std.testing.allocator);
    defer deinitDeep(actual, std.testing.allocator);

    try std.testing.expectEqualDeep(expected, actual);
}

test "justify width 8" {
    const words: []const []const u8 = &.{ "a", "brown", "fox", "jumps" };
    const expected: []const []const u8 = &.{
        "a  brown",
        "fox     ",
        "jumps   ",
    };

    const actual = try fullJustify(words, 8, std.testing.allocator);
    defer deinitDeep(actual, std.testing.allocator);

    try std.testing.expectEqualDeep(expected, actual);
}

test "justify width 10" {
    const words: []const []const u8 = &.{ "a", "brown", "fox", "jumps" };
    const expected: []const []const u8 = &.{
        "a    brown",
        "fox  jumps",
    };

    const actual = try fullJustify(words, 10, std.testing.allocator);
    defer deinitDeep(actual, std.testing.allocator);

    try std.testing.expectEqualDeep(expected, actual);
}

test "justify width 22" {
    const words: []const []const u8 = &.{ "a", "brown", "fox", "jumps" };
    const expected: []const []const u8 = &.{
        "a   brown   fox  jumps",
    };

    const actual = try fullJustify(words, 22, std.testing.allocator);
    defer deinitDeep(actual, std.testing.allocator);

    try std.testing.expectEqualDeep(expected, actual);
}

fn deinitDeep(actual: [][]u8, allocator: std.mem.Allocator) void {
    for (actual) |line| {
        allocator.free(line);
    }
    allocator.free(actual);
}
