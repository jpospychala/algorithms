const std = @import("std");

// You are given an integer array nums. You are initially positioned at the array's first index,
// and each element in the array represents your maximum jump length at that position.
// Return true if you can reach the last index, or false otherwise.
// https://leetcode.com/problems/jump-game/

fn jump_game(nums: []usize) bool {
    // starting from last num, go back to find the closest next num from which we can jump back to the last num.
    // once we found it, repeat but trying to jump to the just found num.
    // nums.len == 1 is final confirmation that we jumped to the start

    if (nums.len == 1) {
        return true;
    }

    var jump: usize = 1;
    while (nums[nums.len - 1 - jump] < jump) {
        jump += 1;
        if (jump > nums.len - 1) {
            return false;
        }
    }

    return jump_game(nums[0 .. nums.len - jump]);
}

test "positive 2 3 1 1 4" {
    var nums = [_]usize{ 2, 3, 1, 1, 4 };
    try std.testing.expectEqual(true, jump_game(&nums));
}

test "negative 3 2 1 0 4" {
    var nums = [_]usize{ 3, 2, 1, 0, 4 };
    try std.testing.expectEqual(false, jump_game(&nums));
}
