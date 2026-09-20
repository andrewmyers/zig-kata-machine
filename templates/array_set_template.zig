const std = @import("std");
const Allocator = std.mem.Allocator;

const empty = ArraySet{ .items = &.{}, .capacity = 0 };

const ArraySet = struct {
    items: []u32, // Note: len is part of items
    capacity: usize,

    pub fn insert(self: *ArraySet, gpa: Allocator, item: u32) usize {
        //... Your solution here
        _ = self;
        _ = gpa;
        _ = item;

        return 0;
    }

    pub fn delete(self: *ArraySet, value: u32) ?usize {
        //... Your solution here
        _ = self;
        _ = value;

        return 0;
    }

    fn search(self: *ArraySet, value: u32) ?usize {
        //... Your solution here
        _ = self;
        _ = value;

        return null;
    }

    pub fn deinit(self: ArraySet, gpa: Allocator) void {
        gpa.free(self.items.ptr[0..self.capacity]);
    }

    fn ensureCapacity(self: *ArraySet, gpa: Allocator, required_capacity: usize) void {
        if (self.capacity >= required_capacity) return;

        const init_capacity: comptime_int = @max(1, std.atomic.cache_line / @sizeOf(u32));
        const new_capacity = required_capacity +| (required_capacity / 2 + init_capacity);

        const old_memory = self.items.ptr[0..self.capacity];
        if (gpa.remap(old_memory, new_capacity)) |new_memory| {
            self.items.ptr = new_memory.ptr;
            self.capacity = new_memory.len;
        } else {
            const new_memory = gpa.alignedAlloc(u32, null, new_capacity) catch {
                std.debug.panic("Out of memory", .{});
            };

            @memcpy(new_memory[0..self.items.len], self.items);
            gpa.free(old_memory);
            self.items.ptr = new_memory.ptr;
            self.capacity = new_memory.len;
        }
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
const test_insert_sorted = [_]u32{ 0, 7, 11, 12, 32, 90 };
const not_in_xs = 100;

test "Insert" {
    const allocator = testing.allocator;

    var xs = empty;
    defer xs.deinit(allocator);

    for (test_insert, 1..) |value, i| {
        try testing.expect(xs.insert(allocator, value) == i);
    }

    try testing.expect(xs.items.len == test_insert.len);

    // No duplicate values inserted
    try testing.expect(xs.insert(allocator, test_insert[0]) == test_insert.len);

    for (test_insert_sorted, xs.items) |expected, value| {
        try testing.expect(expected == value);
    }
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

    for (test_insert_sorted, 0..) |search, expected| {
        try testing.expect(xs.search(search) == expected);
    }

    try testing.expect(xs.search(not_in_xs) == null);
}
