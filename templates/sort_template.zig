const std = @import("std");
const swap = std.mem.swap;

pub fn sort(xs: []u32) void {
    //... Your solution here
    _ = xs;
}

const testing = std.testing;
const asc = std.mem.sort.asc;

fn isSorted(xs: []u32) bool {
    for (0..xs.len) |i| {
        if (i > 0 and xs[i] < xs[i - 1]) {
            return false;
        }
    }

    return true;
}

const TestCase = struct {
    name: []const u8,
    items: []const u32,
};

test "sort" {
    const cases = [_]TestCase{
        .{ .name = "Empty", .items = &.{} },
        .{ .name = "One item", .items = &.{11} },
        .{ .name = "Two items sorted", .items = &.{ 11, 12 } },
        .{ .name = "Two items reversed", .items = &.{ 11, 10 } },
        .{ .name = "Multiple items sorted", .items = &.{ 11, 12, 13, 14, 15, 16 } },
        .{ .name = "Multiple items reversed", .items = &.{ 11, 10, 9, 8, 7, 6 } },
        .{ .name = "Multiple items random", .items = &.{ 11, 8, 19, 58, 17, 6 } },
        .{ .name = "All duplicate items", .items = &.{ 5, 5, 5, 5, 5, 5 } },
        .{ .name = "Maximum integer limits", .items = &.{ std.math.maxInt(u32), 42, 0 } },
        .{ .name = "Extreme min and max spread", .items = &.{ 0, std.math.maxInt(u32), 0, std.math.maxInt(u32) } },
    };

    inline for (cases) |case| {
        errdefer std.debug.print("\n❌ Test case failed: '{s}'\n", .{case.name});

        var test_buffer: [case.items.len]u32 = undefined;
        @memcpy(&test_buffer, case.items);

        sort(&test_buffer);

        try testing.expect(isSorted(&test_buffer));
    }
}

test "test with large random array" {
    var prng = std.Random.DefaultPrng.init(42);
    const random = prng.random();

    const size = 1000;
    var test_buffer: [size]u32 = undefined;

    for (&test_buffer) |*item| {
        item.* = random.int(u32);
    }

    testing.expect(!isSorted(&test_buffer)) catch {
        std.debug.print("The array is already sorted...", .{});
    };

    sort(&test_buffer);

    try testing.expect(isSorted(&test_buffer));
}
