// Implement the RandomizedSet class:
// - RandomizedSet() Initializes the RandomizedSet object
// - bool insert(int val) Inserts an item val into the set if not present.
//   Returns true if the item was not present, false otherwise.
// - bool remove(int val) Removes an item val from the set if present.
//   Returns true if the item was present, false otherwise.
// - int getRandom() Returns a random element from the current set of elements
//   (it's guaranteed that at least one element exists when this method is called).
//   Each element must have the same probability of being returned.
//
// You must implement the functions of the class such that each function works in average O(1) time complexity.
// https://leetcode.com/problems/insert-delete-getrandom-o1

const std = @import("std");

const RandomizedSet = struct {
    keyCounts: std.hash_map.AutoHashMap(usize, usize),
    keys: std.ArrayList(usize),

    fn init(allocator: std.mem.Allocator) RandomizedSet {
        return .{
            .keyCounts = std.hash_map.AutoHashMap(usize, usize).init(allocator),
            .keys = std.ArrayList(usize).init(allocator),
        };
    }

    fn deinit(this: *RandomizedSet) void {
        this.keyCounts.deinit();
        this.keys.deinit();
    }

    fn insert(this: *RandomizedSet, val: usize) !bool {
        const idx = this.keyCounts.get(val);
        if (idx) |_| {
            return false;
        } else {
            try this.keys.append(val);
            try this.keyCounts.put(val, this.keys.items.len - 1);
            return true;
        }
    }

    fn remove(this: *RandomizedSet, val: usize) !bool {
        const removed = this.keyCounts.fetchRemove(val);
        if (removed) |kv| {
            if (kv.value != this.keys.items.len - 1) {
                this.keys.items[kv.value] = this.keys.items[this.keys.items.len - 1];
                try this.keyCounts.put(this.keys.items[kv.value], kv.value);
            }
            this.keys.shrinkRetainingCapacity(this.keys.items.len - 1);
            return true;
        }
        return false;
    }

    fn getRandom(this: *RandomizedSet) usize {
        const rnd = std.crypto.random.intRangeLessThan(usize, 0, this.keys.items.len);
        return this.keys.items[rnd];
    }
};

test "insert() getRandom()" {
    var rs = RandomizedSet.init(std.testing.allocator);
    defer rs.deinit();

    try std.testing.expectEqual(true, try rs.insert(1));
    try std.testing.expectEqual(1, rs.getRandom());
}

test "insert() returns false on already existing value" {
    var rs = RandomizedSet.init(std.testing.allocator);
    defer rs.deinit();

    try std.testing.expectEqual(true, try rs.insert(1));
    try std.testing.expectEqual(false, try rs.insert(1));
}

test "remove() returns false on non-existing value" {
    var rs = RandomizedSet.init(std.testing.allocator);
    defer rs.deinit();

    try std.testing.expectEqual(false, try rs.remove(1));
    _ = try rs.insert(1);
    try std.testing.expectEqual(true, try rs.remove(1));
    try std.testing.expectEqual(false, try rs.remove(1));
}

test "insert() and remove(getRandom()) many times, results with empty set" {
    var rs = RandomizedSet.init(std.testing.allocator);
    defer rs.deinit();

    const count: usize = 100;
    var inserts: usize = 0;

    for (0..count) |_| {
        const rnd = std.crypto.random.intRangeAtMost(usize, 0, 100_000_000);
        if (try rs.insert(rnd)) {
            inserts += 1;
        }
    }

    while (inserts > 0) : (inserts -= 1) {
        _ = try rs.remove(rs.getRandom());
    }

    try std.testing.expectEqual(0, rs.keys.items.len);
    try std.testing.expectEqual(0, rs.keyCounts.count());
}

test "O(1) insert, remove, getRandom" {
    var rs = RandomizedSet.init(std.testing.allocator);
    defer rs.deinit();

    var samples = [_]usize{0} ** 100;
    const sample_size = 100_000;
    for (0..samples.len) |run| {
        const startTs = std.time.milliTimestamp();
        for (0..sample_size) |j| {
            _ = try rs.insert(run * 1000 + j);
        }
        samples[run] = @intCast(std.time.milliTimestamp() - startTs);
    }
    const meanStart = mean(samples[0..10]);
    const meanEnd = mean(samples[samples.len - 10 .. samples.len]);
    std.debug.print("insert: meanStart {d} meanEnd {d}\n", .{ meanStart, meanEnd });
    try std.testing.expect(@abs(meanStart - meanEnd) < meanStart * 10);
}

test "O(1) remove" {
    var rs = RandomizedSet.init(std.testing.allocator);
    defer rs.deinit();

    var samples = [_]usize{0} ** 100;
    const sample_size = 100_000;

    for (0..samples.len) |run| {
        for (0..sample_size) |j| {
            _ = try rs.insert(run * 1000 + j);
        }
    }

    for (0..samples.len) |run| {
        const startTs = std.time.milliTimestamp();
        for (0..sample_size) |j| {
            _ = try rs.remove(run * 1000 + j);
        }
        samples[run] = @intCast(std.time.milliTimestamp() - startTs);
    }
    const meanStart = mean(samples[0..10]);
    const meanEnd = mean(samples[samples.len - 10 .. samples.len]);
    std.debug.print("remove: meanStart {d} meanEnd {d}\n", .{ meanStart, meanEnd });
    try std.testing.expect(@abs(meanStart - meanEnd) < meanStart * 10);
}

test "O(1) getRandom" {
    var rs = RandomizedSet.init(std.testing.allocator);
    defer rs.deinit();

    var samples = [_]usize{0} ** 100;
    const sample_size = 100_000;

    for (0..samples.len) |run| {
        for (0..sample_size) |j| {
            _ = try rs.insert(run * 1000 + j);
        }

        const startTs = std.time.milliTimestamp();
        for (0..sample_size) |_| {
            _ = rs.getRandom();
        }
        samples[run] = @intCast(std.time.milliTimestamp() - startTs);
    }
    const meanStart = mean(samples[0..10]);
    const meanEnd = mean(samples[samples.len - 10 .. samples.len]);
    std.debug.print("getRandom: meanStart {d} meanEnd {d}\n", .{ meanStart, meanEnd });
    try std.testing.expect(@abs(meanStart - meanEnd) < meanStart * 10);
}

test "getRandom each element has equal probability of getting returned" {}

fn mean(samples: []usize) f64 {
    var sum: f64 = 0;
    for (samples) |sample| {
        sum += @as(f64, @floatFromInt(sample));
    }
    return sum / @as(f64, @floatFromInt(samples.len));
}

fn stddev(samples: []usize) f64 {
    const m = mean(samples);
    var sumDiffSquares: f64 = 0;
    for (samples) |sample| {
        const fSample = @as(f64, @floatFromInt(sample));
        sumDiffSquares += (fSample - m) * (fSample - m);
    }
    return std.math.sqrt(sumDiffSquares / @as(f64, @floatFromInt(samples.len)));
}
