const std = @import("std");
const Allocator = std.mem.Allocator;

const ArrayError = error{ IndexOutOfBounds, MemoryError };

const Array = struct {
    items: []u32, // Note: len is part of items
    capacity: usize,

    pub fn insert(self: *Array, gpa: Allocator, i: usize, item: u32) ArrayError!void {
        //... Your solution here
        _ = self;
        _ = gpa;
        _ = i;
        _ = item;
    }

    pub fn delete(self: *Array, i: usize) ArrayError!u32 {
        //... Your solution here
        _ = self;
        _ = i;

        return 0;
    }

    pub fn get(self: *Array, i: usize) ArrayError!u32 {
        //... Your solution here
        _ = self;
        _ = i;

        return 0;
    }

    pub fn search(self: *Array, value: u32) ?usize {
        //... Your solution here
        _ = self;
        _ = value;

        return null;
    }
};

const testing = std.testing;

test "Init" {
    const xs = Array{ .items = &.{}, .capacity = 0 };

    try testing.expect(xs.items.len == 0);
    try testing.expect(xs.capacity == 0);
}

test "Insert" {}

test "Delete" {}

test "Search" {}

test "Get" {}

test "Duplicate entries" {
    // Your test here
}
