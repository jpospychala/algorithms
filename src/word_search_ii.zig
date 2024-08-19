// https://leetcode.com/problems/word-search-ii/

const std = @import("std");

// TODO another impl is to just search the board and mark nodes as visited.

const TrieNode = struct {
    char: u8,
    used: bool = false,
    next: [4]?*TrieNode,

    fn find(this: *TrieNode, word: []const u8) bool {
        if (word.len == 0) {
            return true;
        }

        for (this.next) |n| {
            if (n) |child| {
                if (child.char == word[0]) {
                    child.used = true;
                    const found = child.find(word[1..]);
                    if (!found) {
                        child.used = false;
                    } else {
                        return found;
                    }
                }
            }
        }

        return false;
    }
};

const Trie = struct {
    nodes: []TrieNode,

    fn init(allocator: std.mem.Allocator, board: []const []const u8) !*Trie {
        const h = board.len;
        const w = board[0].len;
        var trie = try allocator.create(Trie);
        const nodes = try allocator.alloc(TrieNode, w * h);
        for (0..h) |i| {
            for (0..w) |j| {
                var node = &nodes[i * w + j];
                @memset(node.next[0..], null);
                node.char = board[i][j];
                node.used = false;
                if (i > 0) {
                    node.next[0] = &nodes[(i - 1) * w + j];
                }
                if (j > 0) {
                    node.next[1] = &nodes[i * w + j - 1];
                }
                if (i < h - 1) {
                    node.next[2] = &nodes[(i + 1) * w + j];
                }
                if (j < w - 1) {
                    node.next[3] = &nodes[i * w + j + 1];
                }
            }
        }
        trie.nodes = nodes;

        return trie;
    }

    fn find(this: *Trie, word: []const u8) bool {
        for (this.nodes) |*n| {
            var node = n.*;
            if (node.char == word[0]) {
                node.used = true;
                const found = node.find(word[1..]);
                if (!found) {
                    node.used = false;
                } else {
                    return found;
                }
            }
        }
        return false;
    }
};

fn findWords(board: []const []const u8, words: []const []const u8, allocator: std.mem.Allocator) ![][]const u8 {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var result = std.ArrayList([]const u8).init(allocator);
    var trie = try Trie.init(arena.allocator(), board);

    for (words) |word| {
        if (trie.find(word)) {
            try result.append(word);
        }
    }

    return result.toOwnedSlice();
}

test "1" {
    const board = [_][]const u8{
        "oaan",
        "etae",
        "ihkr",
        "iflv",
    };
    const words = [_][]const u8{
        "oath",
        "pea",
        "eat",
        "rain",
    };
    const expected = [_][]const u8{
        "oath",
        "eat",
    };

    const actual = try findWords(&board, &words, std.testing.allocator);
    defer std.testing.allocator.free(actual);
    try std.testing.expectEqualDeep(expected[0..], actual[0..]);
}
