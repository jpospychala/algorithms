const std = @import("std");

const Node = struct {
    v: usize,
    next: ?*Node,
};

const List = struct {
    node: ?*Node = null,
    a: std.mem.Allocator,

    fn add(list: *List, val: usize) !void {
        const node = try list.a.create(Node);
        node.v = val;
        node.next = list.node;

        list.node = node;
    }

    fn remove(list: *List, val: usize) bool {
        var n = list.node;
        var prev: ?*Node = null;
        while (n != null and n.?.v != val) {
            prev = n;
            n = n.?.next;
        }

        if (n != null) {
            if (prev != null) {
                prev.?.next = n.?.next;
            } else {
                list.node = n.?.next;
            }
            list.a.destroy(n.?);
            return true;
        } else {
            return false;
        }
    }
};

fn single_number(nums: []const usize, a: std.mem.Allocator) !usize {
    var list: List = .{
        .a = a,
    };

    for (nums) |num| {
        if (!list.remove(num)) {
            try list.add(num);
        }
    }

    return list.node.?.v;
}

fn single_number_bit(nums: []const usize) usize {
    var ret: usize = 0;

    for (nums) |num| {
        ret ^= num;
    }

    return ret;
}

test "list solution" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const nums: []const usize = &[_]usize{ 4, 1, 2, 2, 1 };
    const actual = single_number(nums, arena.allocator());

    try std.testing.expectEqual(4, actual);
}

test "bit solution" {
    const nums: []const usize = &[_]usize{ 4, 1, 2, 2, 1 };
    const actual = single_number_bit(nums);

    try std.testing.expectEqual(4, actual);
}
