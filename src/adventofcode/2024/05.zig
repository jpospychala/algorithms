const std = @import("std");

const ParseState = enum { rules, updates };

fn task5(input: []const u8, a: std.mem.Allocator) !usize {
    var iter = std.mem.splitScalar(u8, input, '\n');
    var state: ParseState = .rules;
    const rules = std.ArrayList([2]usize);
    var rulesList = rules.init(a);
    defer rulesList.deinit();

    while (iter.next()) |line| {
        if (line.len == 0 and state == .rules) {
            state = .updates;
            continue;
        }

        switch (state) {
            .rules => {
                var ruleIter = std.mem.splitScalar(u8, line, '|');
                const num1 = try std.fmt.parseInt(usize, ruleIter.next().?, 10);
                const num2 = try std.fmt.parseInt(usize, ruleIter.next().?, 10);
                try rulesList.append([2]usize{ num1, num2 });
            },
            .updates => {
                var updateIter = std.mem.splitScalar(u8, line, ',');
                while (updateIter.next()) |numStr| {
                    const num = try std.fmt.parseInt(usize, numStr, 10);
                }
            },
        }
    }

    std.debug.print("{any}", .{rulesList.items});

    return 0;
}

test "1" {
    const input =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;

    const actual = try task5(input, std.testing.allocator);
    try std.testing.expectEqual(143, actual);
}
