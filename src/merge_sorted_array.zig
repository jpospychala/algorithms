const std = @import("std");

// You are given two integer arrays nums1 and nums2, sorted in non-decreasing order,
// and two integers m and n, representing the number of elements in nums1 and nums2
// respectively.
//
// Merge nums1 and nums2 into a single array sorted in non-decreasing order.
//
// The final sorted array should not be returned by the function, but instead be
// stored inside the array nums1. To accommodate this, nums1 has a length of m + n,
// where the first m elements denote the elements that should be merged, and
// the last n elements are set to 0 and should be ignored. nums2 has a length of n.
// https://leetcode.com/problems/merge-sorted-array/

fn merge(nums1: []usize, m: usize, nums2: []usize, n: usize) void {
    var m1 = m;
    var n1 = n;
    var i = m + n;
    while (i > 0) : (i -= 1) {
        var v: usize = undefined;
        if ((m1 > 0 and n1 > 0 and (nums1[m1 - 1] > nums2[n1 - 1])) or (n1 == 0)) {
            v = nums1[m1 - 1];
            if (m1 > 0) {
                m1 -= 1;
            }
        } else {
            v = nums2[n1 - 1];
            if (n1 > 0) {
                n1 -= 1;
            }
        }
        nums1[i - 1] = v;
    }
}

test "example 1" {
    var nums1 = [_]usize{ 1, 2, 3, 0, 0, 0 };
    var nums2 = [_]usize{ 2, 5, 6 };
    merge(&nums1, 3, &nums2, 3);

    try std.testing.expectEqualSlices(usize, &[_]usize{ 1, 2, 2, 3, 5, 6 }, &nums1);
}

test "first list empty" {
    var nums1 = [_]usize{ 0, 0, 0 };
    var nums2 = [_]usize{ 2, 5, 6 };
    merge(&nums1, 0, &nums2, 3);

    try std.testing.expectEqualSlices(usize, &[_]usize{ 2, 5, 6 }, &nums1);
}

test "second list empty" {
    var nums1 = [_]usize{ 1, 2, 3 };
    var nums2 = [_]usize{};
    merge(&nums1, 3, &nums2, 0);

    try std.testing.expectEqualSlices(usize, &[_]usize{ 1, 2, 3 }, &nums1);
}
