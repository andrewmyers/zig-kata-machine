const std = @import("std");
const Allocator = std.mem.Allocator;

const ArrayError = error{ IndexOutOfBounds, OutOfMemory };

const empty = ArrayList{ .items = &.{}, .capacity = 0 };

const ArrayList = struct {
    items: []u32, // Note: len is part of items
    capacity: usize,

    pub fn deinit(self: ArrayList, gpa: Allocator) void {
        //... Your solution here
        _ = self;
        _ = gpa;
    }

    pub fn insert(self: *ArrayList, gpa: Allocator, i: usize, item: u32) ArrayError!void {
        //... Your solution here
        _ = self;
        _ = gpa;
        _ = i;
        _ = item;
    }

    pub fn delete(self: *ArrayList, i: usize) ArrayError!u32 {
        //... Your solution here
        _ = self;
        _ = i;

        return 0;
    }

    pub fn get(self: *ArrayList, i: usize) ArrayError!u32 {
        //... Your solution here
        _ = self;
        _ = i;

        return 0;
    }

    pub fn search(self: *ArrayList, value: u32) ?usize {
        //... Your solution here
        _ = self;
        _ = value;

        return null;
    }
};

const testing = std.testing;

test "Init" {
    const xs = empty;

    try testing.expect(xs.items.len == 0);
    try testing.expect(xs.capacity == 0);
}

test "Insert" {
    const allocator = testing.allocator;

    var xs = empty;
    defer xs.deinit(allocator);

    try xs.insert(allocator, 0, 15);
    try testing.expect(xs.items[0] == 15);
    try testing.expect(xs.items.len == 1);

    try xs.insert(allocator, 0, 32);
    try testing.expect(xs.items.len == 2);

    try testing.expect(xs.items[0] == 32);
    try testing.expect(xs.items[1] == 15);

    try xs.insert(allocator, 1, 8);
    try testing.expect(xs.items.len == 3);
    try testing.expect(xs.items[0] == 32);
    try testing.expect(xs.items[1] == 8);
    try testing.expect(xs.items[2] == 15);

    try xs.insert(allocator, xs.items.len, 99);
    try testing.expect(xs.items.len == 4);
    try testing.expect(xs.items[0] == 32);
    try testing.expect(xs.items[1] == 8);
    try testing.expect(xs.items[2] == 15);
    try testing.expect(xs.items[3] == 99);

    try testing.expectError(ArrayError.IndexOutOfBounds, xs.insert(allocator, xs.items.len + 1, 999));
}

test "Delete" {
    const allocator = testing.allocator;

    var xs = empty;
    defer xs.deinit(allocator);

    const items: [5]u32 = .{ 15, 16, 17, 18, 19 };

    for (items, 0..) |v, i| {
        try xs.insert(allocator, i, v);
    }

    for (items, 0..) |v, i| {
        try testing.expect(xs.items[i] == v);
    }

    try testing.expect(xs.items.len == 5);

    const v1 = try xs.delete(xs.items.len - 1);
    try testing.expect(xs.items.len == 4);
    try testing.expect(v1 == 19);
    try testing.expect(xs.items[xs.items.len - 1] == 18);

    const v2 = try xs.delete(0);
    try testing.expect(xs.items.len == 3);
    try testing.expect(v2 == 15);
    try testing.expect(xs.items[0] == 16);

    const v3 = try xs.delete(1);
    try testing.expect(xs.items.len == 2);
    try testing.expect(v3 == 17);
    try testing.expect(xs.items[0] == 16);
    try testing.expect(xs.items[1] == 18);

    try testing.expectError(ArrayError.IndexOutOfBounds, xs.delete(xs.items.len));
}

test "Get" {
    const allocator = testing.allocator;
    var xs = empty;
    defer xs.deinit(allocator);

    const items: [5]u32 = .{ 15, 1, 11, 18, 32 };

    for (items, 0..) |v, i| {
        try xs.insert(allocator, i, v);
    }

    for (items, 0..) |v, i| {
        try testing.expect(try xs.get(i) == v);
    }

    try testing.expectError(ArrayError.IndexOutOfBounds, xs.get(xs.items.len));
}

test "Search" {
    const allocator = testing.allocator;
    var xs = empty;
    defer xs.deinit(allocator);

    const items: [5]u32 = .{ 15, 1, 11, 18, 32 };

    for (items, 0..) |v, i| {
        try xs.insert(allocator, i, v);
    }

    for (items, 0..) |v, i| {
        try testing.expect(xs.search(v) == i);
    }

    try testing.expect(xs.search(99) == null);
}
