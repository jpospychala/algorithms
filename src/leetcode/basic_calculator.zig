// https://leetcode.com/problems/basic-calculator/

const std = @import("std");

const Token = union(enum) {
    number: isize,
    plus: void,
    minus: void,
    braceOpen: void,
    braceClose: void,
};

const Tokenizer = struct {
    s: []const u8,
    i: usize = 0,

    fn init(s: []const u8) Tokenizer {
        return .{
            .s = s,
        };
    }

    fn next(t: *Tokenizer) ?Token {
        if (t.i == t.s.len) {
            return null;
        }

        const c = t.s[t.i];
        t.i += 1;
        return switch (c) {
            '+' => Token.plus,
            '-' => Token.minus,
            '(' => Token.braceOpen,
            ')' => Token.braceClose,
            '0'...'9' => Token{ .number = t.readNum(c - '0') },
            else => next(t),
        };
    }

    fn readNum(t: *Tokenizer, num: isize) isize {
        if (t.i == t.s.len) {
            return num;
        }

        const c = t.s[t.i];
        if (c >= '0' and c <= '9') {
            t.i += 1;
            return t.readNum(num * 10 + (c - '0'));
        }
        return num;
    }
};

const Stack = struct {
    result: isize = 0,
    sign: isize = 1,
    parent: ?*Stack = null,

    fn init(allocator: std.mem.Allocator) !*Stack {
        var stack = try allocator.create(Stack);
        stack.result = 0;
        stack.sign = 1;
        return stack;
    }
};

fn calculate(s: []const u8, allocator: std.mem.Allocator) !isize {
    var stack: *Stack = try Stack.init(allocator);
    defer allocator.destroy(stack);

    var t = Tokenizer.init(s);
    while (t.next()) |token| {
        switch (token) {
            Token.plus => stack.*.sign = 1,
            Token.minus => stack.*.sign = -1,
            Token.number => |v| stack.*.result += stack.*.sign * v,
            Token.braceOpen => {
                const newStack: *Stack = try Stack.init(allocator);
                newStack.parent = stack;
                stack = newStack;
            },
            Token.braceClose => {
                const oldStack = stack;
                stack = stack.*.parent.?;
                stack.*.result += stack.*.sign * oldStack.*.result;
                allocator.destroy(oldStack);
            },
        }
    }

    return stack.result;
}

test "1 + 1" {
    try std.testing.expectEqual(2, calculate("1 + 1", std.testing.allocator));
}

test "2 - 1 + 2" {
    try std.testing.expectEqual(3, calculate("2 - 1 + 2", std.testing.allocator));
}

test "-1" {
    try std.testing.expectEqual(-1, calculate("-1", std.testing.allocator));
}

test "-1-1" {
    try std.testing.expectEqual(-2, calculate("-1-1", std.testing.allocator));
}

test "-1+1" {
    try std.testing.expectEqual(0, calculate("-1+1", std.testing.allocator));
}

test "2-(1+1)" {
    try std.testing.expectEqual(0, calculate("2-(1+1)", std.testing.allocator));
}

test "2-(1-1)" {
    try std.testing.expectEqual(2, calculate("2-(1-1)", std.testing.allocator));
}

test "2-(1-(1+(-1+(-1+1))))" {
    try std.testing.expectEqual(1, calculate("2-(1-(1+(-1+(-1+1))))", std.testing.allocator));
}
