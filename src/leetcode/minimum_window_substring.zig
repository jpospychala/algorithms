// https://leetcode.com/problems/minimum-window-substring/

const std = @import("std");

fn minWindow(s: []const u8, t: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    var min: ?Window = null;
    var window: Window = .{};
    var offsets = std.AutoHashMap(u8, ArrayWithCounter).init(allocator);
    defer offsets.deinit();

    for (t) |c| {
        if (offsets.getEntry(c)) |v| {
            v.value_ptr.*.size += 1;
        } else {
            const a = ArrayWithCounter.init(allocator);
            try offsets.put(c, a);
        }
    }
    defer for (t) |c| {
        offsets.getEntry(c).?.value_ptr.deinit();
    };

    for (s, 0..) |c, i| {
        if (offsets.getEntry(c)) |v| {
            if (window.from == null) {
                window.from = i;
            }
            const hasOld = try v.value_ptr.*.push(i);
            if (hasOld) |old| {
                if (old == window.from) {
                    window.from = minOffset(&offsets).?;
                }
            }
            if (hasAll(&offsets)) {
                window.to = i;
                if ((min == null) or (window.size() < min.?.size())) {
                    min = .{
                        .from = window.from,
                        .to = window.to,
                    };
                }
            }
        }
    }

    if (min) |m| {
        return s[m.from.? .. m.to.? + 1];
    } else {
        return "";
    }
}

fn minOffset(offsets: *std.AutoHashMap(u8, ArrayWithCounter)) ?usize {
    var min: ?usize = null;
    var o = offsets.valueIterator();
    while (o.next()) |i| {
        if (i.array.items.len > 0 and (min == null or i.array.items[0] < min.?)) {
            min = i.array.items[0];
        }
    }

    return min;
}

fn hasAll(offsets: *std.AutoHashMap(u8, ArrayWithCounter)) bool {
    var o = offsets.valueIterator();
    while (o.next()) |i| {
        if (i.array.items.len == 0) {
            return false;
        }
    }

    return true;
}

const Window = struct {
    from: ?usize = null,
    to: ?usize = null,

    fn size(self: *Window) usize {
        return self.*.to.? - self.*.from.? + 1;
    }
};

const ArrayWithCounter = struct {
    size: usize,
    array: std.ArrayList(usize),

    fn init(allocator: std.mem.Allocator) ArrayWithCounter {
        return .{
            .size = 1,
            .array = std.ArrayList(usize).init(allocator),
        };
    }

    fn deinit(self: *ArrayWithCounter) void {
        self.*.array.deinit();
    }

    fn push(self: *ArrayWithCounter, v: usize) !?usize {
        try self.array.insert(0, v);
        if (self.array.items.len > self.size) {
            const ret = self.array.items[1];
            try self.array.resize(self.size);
            return ret;
        }
        return null;
    }
};

test "ArrayWith Counter init/deinit" {
    for (0..3) |_| {
        var a = ArrayWithCounter.init(std.testing.allocator);
        defer a.deinit();

        _ = try a.push(1);
        _ = try a.push(2);
        try std.testing.expect(a.array.items[0] == 2);
    }
}

test "s = ADOBECODEBANC t = ABC" {
    const s = "ADOBECODEBANC";
    const t = "ABC";
    const actual = try minWindow(s, t, std.testing.allocator);

    try std.testing.expectEqualStrings("BANC", actual);
}
