const std = @import("std");

const TreeNode = struct {
    val: isize,
    left: ?*TreeNode,
    right: ?*TreeNode,

    fn initFromList(nodes: []const ?isize, allocator: std.mem.Allocator) !?*TreeNode {
        if ((nodes.len == 0) or (nodes[0] == null)) {
            return null;
        }

        var root = try allocator.create(TreeNode);
        root.val = nodes[0].?;
        root.left = null;
        root.right = null;
        if (nodes.len > 1) {
            const mid = 1 + (nodes.len - 1) / 2;
            root.left = try TreeNode.initFromList(nodes[1..mid], allocator);
            if (mid < nodes.len) {
                root.right = try TreeNode.initFromList(nodes[mid..nodes.len], allocator);
            }
        }
        return root;
    }

    fn deinit(node: *TreeNode, allocator: std.mem.Allocator) void {
        if (node.left) |left| {
            left.deinit(allocator);
        }
        if (node.right) |right| {
            right.deinit(allocator);
        }
        allocator.destroy(node);
    }
};

//   1
// 2   3
//4 5 6 7
// for each node, calculate path sum through node or max(l, r) + node.val. Max(path through node, l-path through node, r-path through-node) and max(l path, r path) + node
// dla każdego node, policz sumę ścieżki przez wierzchołek oraz max(l,p)+wieżchołek. max(ścieżka przez wierzchołek, l-ścieżka przez wierzchołek, p-ścieżka przez wierzchołek) oraz max(l,p)+wieżchołek

//   50
//-10   0
//11 1 0 0

fn max_path_sum(root: ?*TreeNode) isize {
    const result = max_path_sum2(root);
    return @max(result.?[0], result.?[1]);
}

fn max_path_sum2(root: ?*TreeNode) ?[2]isize {
    // 0-max path from children,
    // 1-max path including root node
    if (root) |v| {
        const l = max_path_sum2(v.left);
        const r = max_path_sum2(v.right);

        if (l == null and r == null) {
            return [2]isize{ v.val, v.val };
        } else if (l != null and r != null) {
            return [2]isize{
                @max(@max(l.?[0], r.?[0]), l.?[1] + r.?[1] + v.val),
                @max(l.?[1], r.?[1]) + v.val,
            };
        } else {
            const c = l orelse r;
            return [2]isize{
                c.?[0],
                c.?[1] + v.val,
            };
        }
    } else {
        return null;
    }
}

test "1" {
    const nodes = [_]?isize{ 0, 1, 2 };
    var tree = try TreeNode.initFromList(&nodes, std.testing.allocator);
    defer tree.?.deinit(std.testing.allocator);
    try std.testing.expectEqual(3, max_path_sum(tree));
}

test "childless node" {
    const nodes = [_]?isize{1};
    var tree = try TreeNode.initFromList(&nodes, std.testing.allocator);
    defer tree.?.deinit(std.testing.allocator);
    try std.testing.expectEqual(1, max_path_sum(tree));
}

test "node w/o left child" {
    const nodes = [_]?isize{ 1, 2 };
    var tree = try TreeNode.initFromList(&nodes, std.testing.allocator);
    defer tree.?.deinit(std.testing.allocator);
    try std.testing.expectEqual(3, max_path_sum(tree));
}

test "node w/o right child" {
    const nodes = [_]?isize{ 1, 2, null };
    var tree = try TreeNode.initFromList(&nodes, std.testing.allocator);
    defer tree.?.deinit(std.testing.allocator);
    try std.testing.expectEqual(3, max_path_sum(tree));
}

test "2" {
    const nodes = [_]?isize{ -10, 9, null, null, 20, 15, 7 };
    var tree = try TreeNode.initFromList(&nodes, std.testing.allocator);
    defer tree.?.deinit(std.testing.allocator);
    try std.testing.expectEqual(42, max_path_sum(tree));
}
