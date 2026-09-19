const std = @import("std");
const Allocator = std.mem.Allocator;

const empty = ArraySet{ .items = &.{}, .capacity = 0 };

const ArraySet = struct {
    items: []u32, // Note: len is part of items
    capacity: usize,

    pub fn deinit(self: ArraySet, gpa: Allocator) void {
        //... Your solution here
        _ = self;
        _ = gpa;
    }

    pub fn insert(self: *ArraySet, gpa: Allocator, item: u32) usize {
        //... Your solution here
        _ = self;
        _ = gpa;
        _ = item;

        return 0;
    }

    pub fn delete(self: *ArraySet, i: usize) ?usize {
        //... Your solution here
        _ = self;
        _ = i;

        return 0;
    }

    fn search(self: *ArraySet, value: u32) ?usize {
        //... Your solution here
        _ = self;
        _ = value;

        return null;
    }

    fn ensureCapacity(self: *ArraySet, gpa: Allocator, required_capacity: usize) void {
        //... Your solution here
        _ = self;
        _ = gpa;
        _ = required_capacity;
    }
};

const testing = std.testing;

pub fn isSorted(xs: []u32) bool {
    for (0..xs.len) |i| {
        if (i > 0 and xs[i] < xs[i - 1]) {
            return false;
        }
    }

    return true;
}

test "Init" {
    const xs = empty;

    try testing.expect(xs.items.len == 0);
    try testing.expect(xs.capacity == 0);
}

const test_insert = [_]u32{ 11, 12, 0, 90, 7, 32 };
const not_in_xs = 100;

test "Insert" {
    const allocator = testing.allocator;

    var xs = empty;
    defer xs.deinit(allocator);

    for (test_insert, 1..) |value, i| {
        try testing.expect(xs.insert(allocator, value) == i);
    }

    try testing.expect(xs.items.len == test_insert.len);

    try testing.expect(isSorted(xs.items));
}

test "Delete" {
    const allocator = testing.allocator;

    var xs = empty;
    defer xs.deinit(allocator);

    for (test_insert) |value| {
        _ = xs.insert(allocator, value);
    }

    try testing.expect(xs.delete(90) == test_insert.len - 1);
    try testing.expect(xs.delete(0) == test_insert.len - 2);
    try testing.expect(xs.delete(11) == test_insert.len - 3);
    try testing.expect(xs.delete(not_in_xs) == null);

    try testing.expect(xs.items.len == test_insert.len - 3);
    try testing.expect(isSorted(xs.items));
}

test "Search" {
    const allocator = testing.allocator;
    var xs = empty;
    defer xs.deinit(allocator);

    try testing.expect(xs.search(11) == null);

    for (test_insert) |value| {
        _ = xs.insert(allocator, value);
    }

    try testing.expect(xs.search(11) == 2);

    try testing.expect(xs.search(not_in_xs) == null);
}
