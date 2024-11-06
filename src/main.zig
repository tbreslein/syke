const std = @import("std");
const Args = @import("args.zig").Args;
const ziglua = @import("ziglua");

const Lua = ziglua.Lua;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try Args.init();
    defer args.deinit();

    var lua = try Lua.init(allocator);
    defer lua.deinit();

    // TODO: check if the file even exists before dumping it into lua.doFile
    // TODO: better error handling
    try lua.doFile(args.file);

    std.debug.print("isTable = {}\n", .{lua.isTable(-1)});
    _ = lua.getField(-1, "foo");
    std.debug.print("foo isTable = {}\n", .{lua.isTable(-1)});
    _ = lua.getField(-1, "bar");
    std.debug.print("bar isInteger = {}\n", .{lua.isInteger(-1)});
    const bar = lua.toInteger(-1);
    std.debug.print("bar = {any}\n", .{bar});
    lua.pop(2);

    _ = lua.getField(-1, "symlinks");
    std.debug.print("symlinks isTable = {}\n", .{lua.isTable(-1)});
    _ = lua.len(-1);
    std.debug.print("symlinks.len = {any}\n", .{lua.toInteger(-1)});
}
