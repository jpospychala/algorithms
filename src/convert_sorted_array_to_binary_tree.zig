// Given an integer array nums where the elements are sorted in ascending order, convert it to a
// height-balanced binary search tree.
// https://leetcode.com/problems/convert-sorted-array-to-binary-search-tree/

// answer: take the middle element of nums array, use it as TreeNode value,
// populate tree left hand side with lower half of nums array,
// populate tree right hand size with upper half of nums array.

const std = @import("std");

const TreeNode = struct {
    val: usize,
    left: ?*TreeNode = null,
    right: ?*TreeNode = null,

    fn init(val: TreeNode, allocator: std.mem.Allocator) !*TreeNode {
        var ret = try allocator.create(TreeNode);
        ret.val = val.val;
        ret.left = val.left;
        ret.right = val.right;
        return ret;
    }

    fn deinit(self: *TreeNode, allocator: std.mem.Allocator) void {
        if (self.left) |left| {
            left.deinit(allocator);
        }
        if (self.right) |right| {
            right.deinit(allocator);
        }

        allocator.destroy(self);
    }
};

fn sorted_array_to_bst(nums: []const usize, a: std.mem.Allocator) !?*TreeNode {
    if (nums.len == 0) {
        return null;
    }

    const midIdx = nums.len / 2;
    const mid = try TreeNode.init(.{
        .val = nums[midIdx],
        .left = try sorted_array_to_bst(nums[0..midIdx], a),
        .right = try sorted_array_to_bst(nums[midIdx + 1 .. nums.len], a),
    }, a);
    return mid;
}

test "nums.len/2" {
    const nums = [_]usize{ 0, 1, 2, 3 };
    for (nums[4..nums.len]) |i| {
        std.debug.print("{}", .{i});
    }
}

test "null" {
    try std.testing.expectEqualDeep(null, try sorted_array_to_bst(&[_]usize{}, std.testing.allocator));
}

test "1 3" {
    const aloc = std.testing.allocator;
    const nums = [_]usize{ 1, 3 };
    const res = try sorted_array_to_bst(&nums, aloc) orelse unreachable;
    const expected = try TreeNode.init(.{
        .val = 3,
        .left = try TreeNode.init(.{ .val = 1 }, aloc),
    }, aloc);

    defer res.deinit(aloc);
    defer expected.deinit(aloc);

    try std.testing.expectEqual(expected.val, res.val);
}

test "1 2 3 4 5" {
    const aloc = std.testing.allocator;
    const nums = [_]usize{ 1, 2, 3, 4, 5 };
    const res = try sorted_array_to_bst(&nums, aloc) orelse unreachable;
    const expected = try TreeNode.init(.{
        .val = 3,
        .left = try TreeNode.init(.{
            .val = 1,
            .left = try TreeNode.init(.{ .val = 2 }, aloc),
        }, aloc),
        .right = try TreeNode.init(.{
            .val = 5,
            .right = try TreeNode.init(.{ .val = 4 }, aloc),
        }, aloc),
    }, aloc);

    defer res.deinit(aloc);
    defer expected.deinit(aloc);

    try std.testing.expectEqual(expected.val, res.val);
}
