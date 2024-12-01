// https://leetcode.com/problems/reverse-bits/

const std = @import("std");

fn reverseBits(number: u32) u32 {
    var num = number;
    var ret: u32 = 0;
    for (0..31) |_| {
        ret = (ret | (num % 2)) << 1;
        num = num >> 1;
    }
    return ret;
}

test {
    try std.testing.expectEqual(0b00111001011110000010100101000000, reverseBits(0b00000010100101000001111010011100));
}
