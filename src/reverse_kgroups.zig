// https://leetcode.com/problems/reverse-nodes-in-k-group

const std = @import("std");

const ListNode = struct {
    val: usize = 0,
    next: ?*ListNode = null,

    fn initList(nums: []const usize, allocator: std.mem.Allocator) !*ListNode {
        var first: ?*ListNode = null;
        var prev: ?*ListNode = null;
        for (nums, 0..) |n, i| {
            const node = try allocator.create(ListNode);
            node.val = n;
            node.next = null;
            if (i == 0) {
                first = node;
            } else {
                prev.?.next = node;
            }
            prev = node;
        }

        return first.?;
    }

    fn deinit(node: ?*ListNode, allocator: std.mem.Allocator) void {
        var curr: ?*ListNode = node;
        while (curr) |n| {
            curr = n.next;
            allocator.destroy(n);
        }
    }

    fn toArray(node: *ListNode, allocator: std.mem.Allocator) ![]usize {
        var array = std.ArrayList(usize).init(allocator);
        var curr: ?*ListNode = node;
        while (curr) |n| {
            try array.append(n.val);
            curr = n.next;
        }
        return array.toOwnedSlice();
    }

    fn sizeAtLeast(node: *ListNode, count: usize) bool {
        var curr: ?*ListNode = node;
        var i: usize = 0;
        while (curr) |n| {
            i += 1;
            if (i == count) {
                return true;
            }
            curr = n.next;
        }
        return false;
    }
};

fn reverseKGroup(node: ?*ListNode, k: usize) *ListNode {
    var head: ?*ListNode = null;
    var tail: ?*ListNode = null;
    var groupHead: ?*ListNode = null;
    var groupTail: ?*ListNode = null;
    var i: usize = 0;

    // czytaj elementy z listy po jednym,
    // pierwszy element zostanie ogonem sekcji (newTail)
    // kazdy kolejny element doczepiaj jako głowa sekcji (newHead)
    // gdy liczba doczepionych elementów = k i nie ma głowy listy to głowa sekcji (newHead) staje się głową listy (head),
    // jesli jest ogon (tail) to głowa sekcji (newHead) staje się nextem ogona (tail). Nowym ogonem (tail) staje się ogon sekcji (newTail)

    var curr = node;
    while (curr) |c| {
        i += 1;

        if ((i == 1) and (!c.sizeAtLeast(k))) {
            if (tail) |t| {
                t.next = c;
                return head.?;
            } else {
                return c;
            }
        }

        const next = c.next;
        c.next = groupHead;
        groupHead = c;

        if (i == 1) {
            groupTail = groupHead;
        }

        if (i == k) {
            if (head == null) {
                head = groupHead;
            }
            if (tail) |t| {
                t.next = groupHead;
            }
            tail = groupTail;
            tail.?.next = null;
            i = 0;
        }

        curr = next;
    }

    return head.?;
}

test "1 2 3 4, k 4" {
    const nums = [_]usize{ 1, 2, 3, 4 };
    const expected = [_]usize{ 4, 3, 2, 1 };
    var list = try ListNode.initList(&nums, std.testing.allocator);
    defer list.deinit(std.testing.allocator);

    list = reverseKGroup(list, 4);

    const actual = try list.toArray(std.testing.allocator);
    defer std.testing.allocator.free(actual);

    try std.testing.expectEqualSlices(usize, &expected, actual);
}

test "1 2 3 4 5 6 7 8, k 4" {
    const nums = [_]usize{ 1, 2, 3, 4, 5, 6, 7, 8 };
    const expected = [_]usize{ 2, 1, 4, 3, 6, 5, 8, 7 };
    var list = try ListNode.initList(&nums, std.testing.allocator);
    defer list.deinit(std.testing.allocator);

    list = reverseKGroup(list, 2);

    const actual = try list.toArray(std.testing.allocator);
    defer std.testing.allocator.free(actual);

    try std.testing.expectEqualSlices(usize, &expected, actual);
}

test "1 2 3 4 5, k 3" {
    const nums = [_]usize{ 1, 2, 3, 4, 5 };
    const expected = [_]usize{ 3, 2, 1, 4, 5 };
    var list = try ListNode.initList(&nums, std.testing.allocator);
    defer list.deinit(std.testing.allocator);

    list = reverseKGroup(list, 3);

    const actual = try list.toArray(std.testing.allocator);
    defer std.testing.allocator.free(actual);

    try std.testing.expectEqualSlices(usize, &expected, actual);
}

test "1 2 3 4 5, k 6" {
    const nums = [_]usize{ 1, 2, 3, 4, 5 };
    const expected = [_]usize{ 1, 2, 3, 4, 5 };
    var list = try ListNode.initList(&nums, std.testing.allocator);
    defer list.deinit(std.testing.allocator);

    list = reverseKGroup(list, 6);

    const actual = try list.toArray(std.testing.allocator);
    defer std.testing.allocator.free(actual);

    try std.testing.expectEqualSlices(usize, &expected, actual);
}
