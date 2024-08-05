// Given an array of integers citations where citations[i] is the number of
// citations a researcher received for their ith paper, return the researcher's
// h-index.

// According to the definition of h-index on Wikipedia: The h-index is defined
// as the maximum value of h such that the given researcher has published at
// least h papers that have each been cited at least h times.

// answer: count papers from most cited paper to least cited paper, until we
// find a paper that has less citations than number papers found so far.
// Number of papers found so far is h-index

const std = @import("std");

fn hindex(citations: []usize) usize {
    std.sort.block(usize, citations, {}, std.sort.desc(usize));
    for (citations, 0..) |cit, count| {
        if (cit <= count) {
            return count;
        }
    }

    return citations.len;
}

test "3 0 6 1 5" {
    var citations = [_]usize{ 3, 0, 6, 1, 5 };
    try std.testing.expectEqual(3, hindex(citations[0..]));
}

test "0 0 0" {
    var citations = [_]usize{ 0, 0, 0 };
    try std.testing.expectEqual(0, hindex(citations[0..]));
}

test "1 1 1" {
    var citations = [_]usize{ 1, 1, 1 };
    try std.testing.expectEqual(1, hindex(citations[0..]));
}

test "1 2 3" {
    var citations = [_]usize{ 1, 2, 3 };
    try std.testing.expectEqual(2, hindex(citations[0..]));
}

test "3 3 3" {
    var citations = [_]usize{ 3, 3, 3 };
    try std.testing.expectEqual(3, hindex(citations[0..]));
}
