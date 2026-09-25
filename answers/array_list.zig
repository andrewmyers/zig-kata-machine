const std = @import("std");
const Allocator = std.mem.Allocator;

const ArrayError = error{IndexOutOfBounds};

const empty = ArrayList{ .items = &.{}, .capacity = 0 };

const ArrayList = struct {
    items: []u32,
    capacity: usize,

    pub fn insert(self: *ArrayList, gpa: Allocator, i: usize, item: u32) ArrayError!void {
        if (i > self.items.len) {
            return ArrayError.IndexOutOfBounds;
        }

        self.ensureCapacity(gpa, self.items.len + 1);

        self.items.len += 1;

        var j = self.items.len - 1;
        while (j > i) : (j -= 1) {
            self.items[j] = self.items[j - 1];
        }

        self.items[i] = item;
    }

    pub fn delete(self: *ArrayList, i: usize) ArrayError!u32 {
        if (i > self.items.len - 1) {
            return ArrayError.IndexOutOfBounds;
        }

        const item = self.items[i];

        var j = i;
        while (j < self.items.len - 1) : (j += 1) {
            self.items[j] = self.items[j + 1];
        }

        self.items.len -= 1;

        return item;
    }

    pub fn get(self: *ArrayList, i: usize) ArrayError!u32 {
        if (i > self.items.len - 1) {
            return ArrayError.IndexOutOfBounds;
        }

        return self.items[i];
    }

    pub fn search(self: *ArrayList, value: u32) ?usize {
        return for (self.items, 0..) |item, i| {
            if (item == value) {
                break i;
            }
        } else null;
    }

    pub fn deinit(self: ArrayList, gpa: Allocator) void {
        gpa.free(self.items.ptr[0..self.capacity]);
    }

    fn ensureCapacity(self: *ArrayList, gpa: Allocator, required_capacity: usize) void {
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
