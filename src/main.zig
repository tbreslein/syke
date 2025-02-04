const std = @import("std");

// TODO:
// - add stringbuffer
// - add cli parsing -> config
// - add custom error set
// - add logger
// - add syke table
// - add tests
// - add symlinks
// - add dumping generation to disk
// - add sorting for symlinks
// - add ln command and make it declarative
// - add repos
// - add shell map
// - add pkgs
//   - homebrew
//   - pacman/yay
// - add services

pub fn main() !void {
    std.debug.print("foobar", .{});
    // var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // const allocator = arena.allocator();
    // defer _ = arena.deinit();
}
