// https://leetcode.com/problems/substring-with-concatenation-of-all-words/

const std = @import("std");

fn findSubstrings(text: []const u8, words: []const []const u8, allocator: std.mem.Allocator) ![]usize {
    // Read text by taking fixed-length words, let's call them tokens.
    // For each token, loop over further tokens as long as token is on words list.
    // For each token found on list tag it as found, to avoid finding the same words many times.

    var result = std.ArrayList(usize).init(allocator);
    var foundWords = try allocator.alloc(bool, words.len);
    defer allocator.free(foundWords);

    const wordLen = words[0].len;

    var i: usize = 0;
    while (i < text.len - words.len * wordLen) : (i += wordLen) {
        @memset(foundWords, false);

        var j: usize = i;
        var foundCount: usize = 0;
        while (j < text.len) : (j += wordLen) {
            const word = text[j .. j + wordLen];
            if (!findAndMark(word, words, &foundWords)) {
                break;
            }
            foundCount += 1;
            if (foundCount == words.len) {
                try result.append(i);
                break;
            }
        }
    }

    return result.toOwnedSlice();
}

fn findAndMark(word: []const u8, words: []const []const u8, foundWords: *[]bool) bool {
    for (words, 0..) |w, j| {
        if (!foundWords.*[j] and std.mem.eql(u8, word, w)) {
            foundWords.*[j] = true;
            return true;
        }
    }
    return false;
}

test "success" {
    const s: []const u8 = "barfoothefoobarman";
    const words: []const []const u8 = &.{ "foo", "bar" };

    const actual = try findSubstrings(s, words, std.testing.allocator);
    defer std.testing.allocator.free(actual);

    const expected: []const usize = &[_]usize{ 0, 9 };
    try std.testing.expectEqualSlices(usize, expected, actual);
}

test "no substrings found" {
    const s: []const u8 = "wordgoodgoodgoodbestword";
    const words: []const []const u8 = &.{ "word", "good", "best", "word" };

    const actual = try findSubstrings(s, words, std.testing.allocator);
    defer std.testing.allocator.free(actual);

    const expected: []const usize = &[_]usize{};
    try std.testing.expectEqualSlices(usize, expected, actual);
}

test "overlapping substrings" {
    const s: []const u8 = "barfoofoobarthefoobarman";
    const words: []const []const u8 = &.{ "bar", "foo", "the" };

    const actual = try findSubstrings(s, words, std.testing.allocator);
    defer std.testing.allocator.free(actual);

    const expected: []const usize = &[_]usize{ 6, 9, 12 };
    try std.testing.expectEqualSlices(usize, expected, actual);
}
