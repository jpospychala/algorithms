const std = @import("std");

// algorithm
// for each trailhead (place on map equal 0),
// sum possible trails in 4 directions: top, bottom, left, right.
// going in each direction, if it's value/height is current+1, then follow it
// when reached height is 9, return 1

fn trailheads(in: []const u8, a: std.mem.Allocator) !usize {
    const width: isize = @intCast(1 + (std.mem.indexOfScalar(u8, in, '\n') orelse 0));
    var start: usize = 0;
    var result = std.ArrayList(usize).init(a);
    defer result.deinit();
    var total: usize = 0;

    while (std.mem.indexOfScalarPos(u8, in, start, '0')) |v| {
        try followTrails(in, '0', @intCast(v), width, &result);
        total += result.items.len;
        result.shrinkRetainingCapacity(0);
        start = v + 1;
    }

    return total;
}

fn followTrails(in: []const u8, expected: u8, pos: isize, width: isize, results: *std.ArrayList(usize)) !void {
    if (pos < 0 or pos >= in.len) {
        return;
    }

    const pos2: usize = @intCast(pos);
    if (in[pos2] != expected) {
        return;
    }

    if (expected == '9') {
        if (std.mem.indexOfScalar(usize, results.items, pos2)) |_| {} else {
            try results.append(pos2);
        }
        return;
    }

    try followTrails(in, expected + 1, pos + 1, width, results); // l
    try followTrails(in, expected + 1, pos - 1, width, results); // r
    try followTrails(in, expected + 1, pos + width, width, results); // down
    try followTrails(in, expected + 1, pos - width, width, results); // up
}

test "1" {
    const in =
        \\...0...
        \\...1...
        \\...2...
        \\6543456
        \\7.....7
        \\8.....8
        \\9.....9
    ;
    const actual = try trailheads(in, std.testing.allocator);
    try std.testing.expectEqual(2, actual);
}

test "2" {
    const in =
        \\89010123
        \\78121874
        \\87430965
        \\96549874
        \\45678903
        \\32019012
        \\01329801
        \\10456732
    ;
    const actual = try trailheads(in, std.testing.allocator);
    try std.testing.expectEqual(36, actual);
}

test "final" {
    const actual = try trailheads(finalInput(), std.testing.allocator);
    try std.testing.expectEqual(459, actual);
}

fn finalInput() []const u8 {
    return 
    \\1098921121187650126589432104301010017898
    \\2347810030090543237676546765218921326323
    \\3256723345121789078545345896237635495410
    \\0189654656230650129454210910146546786898
    \\1018706787649843212323407893056544576781
    \\0123215498556764501012216324567033675410
    \\1054912389440189650983345413498122189323
    \\2367804322339218761874214102439232075014
    \\3494565011878307010965302101521001456985
    \\4583876910965498123434456517617652327876
    \\9672978894328767894525467898908543410434
    \\8701569765419456987616321010119654306523
    \\7616054100300345865407890121236701217810
    \\4567123231201210870301456290547896332912
    \\3258834998303456961210387787678987441003
    \\4109985867214327898341295689432196556764
    \\3457876754321016987654254776501001105895
    \\2568965698130123216510163897567232234996
    \\1077654147010154105425672198498143497887
    \\2089503056923269012334789010398056786546
    \\1123412147874678901109011001267049805430
    \\0109892130965165210278921123452121012321
    \\1236783021089014321367630038983430328901
    \\0345634569870156752456541127604589437610
    \\1267825478763247843898430934510678576523
    \\3216910089654130956707321874321987689430
    \\4505432198703021013210012365899654238321
    \\3699801789012982787309898456718723148980
    \\2789789678101276896456721032100210057671
    \\1008650521010345785454434549321321060362
    \\2210541430121289890365410678732639871250
    \\4341232510537656701274320521548747898341
    \\1056341423498545432789201230699656743432
    \\2967650345567230101687112345788745234569
    \\3878981236750121211096001296787230199678
    \\4589870109889032349125410187590123288767
    \\5679665010976541498934231095691054177678
    \\3038754129889650587432145654782567065549
    \\2125603236778765676501098723123478450030
    \\3034512345654656565410181010010989321121
    ;
}
