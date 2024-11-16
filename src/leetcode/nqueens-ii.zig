// https://leetcode.com/problems/n-queens-ii/
const std = @import("std");

const Board = struct {
    n: usize,
    board: [][]u8,
    cols: []bool,
    diag1: []bool,
    diag2: []bool,

    fn init(n: usize, allocator: std.mem.Allocator) !Board {
        var board = try allocator.alloc([]u8, n);
        for (0..n) |i| {
            board[i] = try allocator.alloc(u8, n);
            @memset(board[i], 0);
        }

        const ret = Board{
            .n = n,
            .board = board,
            .cols = try allocator.alloc(bool, n),
            .diag1 = try allocator.alloc(bool, n * 2),
            .diag2 = try allocator.alloc(bool, n * 2),
        };
        @memset(ret.cols, false);
        @memset(ret.diag1, false);
        @memset(ret.diag2, false);
        return ret;
    }

    fn deinit(this: *Board, allocator: std.mem.Allocator) void {
        for (0..this.n) |i| {
            allocator.free(this.board[i]);
        }
        allocator.free(this.board);
        allocator.free(this.cols);
        allocator.free(this.diag1);
        allocator.free(this.diag2);
    }
};

fn nqueens(n: usize, allocator: std.mem.Allocator) !usize {
    var board = try Board.init(n, allocator);
    defer board.deinit(allocator);

    return nqueens2(&board, 0);
}

fn nqueens2(board: *Board, r: usize) usize {
    if (r == board.n) {
        return 1;
    }

    var count: usize = 0;

    for (0..board.n) |c| {
        //std.debug.print("{d} {d} {d} {d} {d}\n", .{ board.n, r, c, r + c, board.n + r - c - 1 });
        if (board.cols[c] or board.diag1[r + c] or board.diag2[board.n + r - c - 1]) {
            continue;
        }

        board.cols[c] = true;
        board.diag1[r + c] = true;
        board.diag2[board.n + r - c - 1] = true;

        count += nqueens2(board, r + 1);

        board.cols[c] = false;
        board.diag1[r + c] = false;
        board.diag2[board.n + r - c - 1] = false;
    }

    return count;
}

test "n=1" {
    const actual = nqueens(1, std.testing.allocator);
    try std.testing.expectEqual(1, actual);
}

test "n=2" {
    const actual = nqueens(2, std.testing.allocator);
    try std.testing.expectEqual(0, actual);
}

test "n=3" {
    const actual = nqueens(3, std.testing.allocator);
    try std.testing.expectEqual(0, actual);
}

test "n=4" {
    const actual = nqueens(4, std.testing.allocator);
    try std.testing.expectEqual(2, actual);
}

test "n=8" {
    const actual = nqueens(8, std.testing.allocator);
    try std.testing.expectEqual(92, actual);
}

test "n=16" {
    const actual = nqueens(14, std.testing.allocator);
    try std.testing.expectEqual(92, actual);
}

// n=1 => 1
//
// x
//
// n=2 => 0
//
// n=3 => 0
//
// n=4 => 2
//
// 0x00
// 000x
// x000
// 00x0
//
// n = 5
//
// 0x000
// 000x0
// x0000
// 00x00
// 0000x
//

// 00000
// 00000
// 0x000
// 00000
// 00000
