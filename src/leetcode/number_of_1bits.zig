// https://leetcode.com/problems/number-of-1-bits

const std = @import("std");

fn hammingWeight(number: u32) u8 {
    var ret: u8 = 0;
    var num = number;
    while (num != 0) {
        ret += @intCast(num % 2);
        num >>= 1;
    }
    return ret;
}

test {
    try std.testing.expectEqual(1, hammingWeight(1));
    try std.testing.expectEqual(5, hammingWeight(0b101010101));
}
