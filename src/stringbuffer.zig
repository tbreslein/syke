const std = @import("std");
const ArrayList = std.ArrayList;

data: ArrayList(u8),

pub fn init(allocator: std.mem.Allocator) @This() {
    return .{ .data = ArrayList(u8).init(allocator) };
}

pub fn deinit(self: *@This()) @This() {
    self.data.deinit();
}

pub fn append(self: *@This(), c: u8) !void {
    self.data.append(c);
}

pub fn appendNTimes(self: *@This(), c: u8, n: usize) !void {
    self.data.appendNTimes(c, n);
}

pub fn appendSlice(self: *@This(), cs: []const u8) !void {
    self.data.appendSlice(cs);
}

pub fn clear(self: *@This()) void {
    self.data.clearRetainingCapacity();
}
