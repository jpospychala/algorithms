const std = @import("std");

// You are given an integer array nums. You are initially positioned at the array's first index,
// and each element in the array represents your maximum jump length at that position.
// Return true if you can reach the last index, or false otherwise.
// https://leetcode.com/problems/jump-game/

fn jump_game(nums: []usize, jumps_so_far: isize) isize {
    // starting from last num, go back to find the closest next num from which we can jump back to the last num.
    // once we found it, repeat but trying to jump to the just found num.
    // nums.len == 1 is final confirmation that we jumped to the start

    if (nums.len == 1) {
        return jumps_so_far;
    }

    var jump: usize = nums.len - 1;
    while (nums[nums.len - 1 - jump] < jump) {
        jump -= 1;
        if (jump == 0) {
            return -1; // can't jump to the end
        }
    }

    return jump_game(nums[0 .. nums.len - jump], jumps_so_far + 1);
}

test "positive 2 3 1 1 4" {
    var nums = [_]usize{ 2, 3, 1, 1, 4 };
    try std.testing.expectEqual(2, jump_game(&nums, 0));
}

test "negative 3 2 1 0 4" {
    var nums = [_]usize{ 3, 2, 1, 0, 4 };
    try std.testing.expectEqual(-1, jump_game(&nums, 0));
}
