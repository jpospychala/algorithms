const std = @import("std");

const ListNode = struct {
    val: usize,
    next: ?*ListNode,

    fn init(val: usize, next: ?*ListNode) ListNode {
        return .{
            .val = val,
            .next = next,
        };
    }
};

fn sort_list(head: *ListNode) *ListNode {
    var curr: ?*ListNode = head.next;
    var result = head;
    result.next = null;

    while (curr != null) {
        const next = curr.?.next;
        curr.?.next = null;

        if (curr.?.val < result.val) {
            curr.?.next = result;
            result = curr.?;
        } else {
            var tmp = result;
            while (tmp.next != null and tmp.next.?.val < curr.?.val) {
                tmp = tmp.next.?;
            }
            if (tmp.next == null) {
                tmp.next = curr;
            } else {
                curr.?.next = tmp.next.?;
                tmp.next = curr;
            }
        }

        curr = next;
    }

    return result;
}

test "sorted" {
    var list = ListNode.init(0, @constCast(&ListNode.init(1, @constCast(&ListNode.init(2, null)))));
    const expected = &ListNode.init(0, @constCast(&ListNode.init(1, @constCast(&ListNode.init(2, null)))));

    const actual = sort_list(&list);

    try std.testing.expectEqualDeep(expected, actual);
}

test "unsorted" {
    var list = ListNode.init(2, @constCast(&ListNode.init(1, @constCast(&ListNode.init(0, null)))));
    const expected = &ListNode.init(0, @constCast(&ListNode.init(1, @constCast(&ListNode.init(2, null)))));

    const actual = sort_list(&list);

    try std.testing.expectEqualDeep(expected, actual);
}

test "1 element" {
    var list = ListNode.init(2, null);
    const expected = &ListNode.init(2, null);

    const actual = sort_list(&list);

    try std.testing.expectEqualDeep(expected, actual);
}
