// https://leetcode.com/problems/word-ladder/

const std = @import("std");

fn dist(w1: []const u8, w2: []const u8, n: usize) bool {
    var d: usize = 0;
    for (w1, 0..) |c, i| {
        if (c != w2[i]) {
            d += 1;
            if (d > n) {
                return false;
            }
        }
    }

    return d == n;
}

fn eq(w1: []const u8, w2: []const u8) bool {
    return dist(w1, w2, 0);
}

fn ladder_length(begin_word: []const u8, end_word: []const u8, word_list: []const []const u8, allocator: std.mem.Allocator) !usize {
    const black_list: []bool = try allocator.alloc(bool, word_list.len);
    defer allocator.free(black_list);

    const end_word_idx = blk: {
        for (word_list, 0..) |w, i| {
            if (eq(end_word, w)) {
                break :blk i;
            }
        }
        return 0; // end word not exists in word_list
    };

    return ladder_length2(begin_word, end_word_idx, word_list, black_list);
}

fn ladder_length2(begin_word: []const u8, end_word_idx: usize, word_list: []const []const u8, black_list: []bool) usize {
    for (word_list, 0..) |w, i| {
        if (black_list[i]) {
            continue;
        }
        if (dist(begin_word, w, 1)) {
            if (i == end_word_idx) {
                return 1;
            } else {
                black_list[i] = true;
                const fnd = ladder_length2(w, end_word_idx, word_list, black_list);
                if (fnd > 0) {
                    return fnd + 1;
                }
                black_list[i] = false;
            }
        }
    }

    return 0;
}

test "1" {
    const begin_word = "hit";
    const end_word = "cog";
    const word_list = [_][]const u8{ "hot", "dot", "dog", "lot", "log", "cog" };

    const actual = try ladder_length(begin_word, end_word, &word_list, std.testing.allocator);

    try std.testing.expectEqual(5, actual);
}
