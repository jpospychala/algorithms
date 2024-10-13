const std = @import("std");
const testing = std.testing;

const ListNode = struct {
    val: usize,
    next: ?*ListNode,

    fn init(val: usize, next: ?*ListNode) ListNode {
        return .{ .val = val, .next = next };
    }

    fn print(next: *ListNode) void {
        if (next.next != null) {
            std.debug.print("{d}->", .{next.val});
            print(next.next.?);
        } else {
            std.debug.print("{d}\n", .{next.val});
        }
    }
};

// 0->1->2

fn reverseList(head: *ListNode) *ListNode {
    if (head.next == null) {
        return head;
    }
    std.debug.print("before: ", .{});
    head.print();
    const rest = reverseList(head.next.?);
    head.next.?.next = head;
    head.next = null;
    std.debug.print("after: ", .{});
    rest.print();
    return rest;
}

test {
    const list = &ListNode.init(0, @constCast(&ListNode.init(1, @constCast(&ListNode.init(2, @constCast(&ListNode.init(3, null)))))));
    const expected = &ListNode.init(3, @constCast(&ListNode.init(2, @constCast(&ListNode.init(1, @constCast(&ListNode.init(0, null)))))));
    const actual = reverseList(@constCast(list));
    try testing.expectEqualDeep(expected, actual);
}
