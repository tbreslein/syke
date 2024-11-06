const std = @import("std");
const clap = @import("clap");
const ziglua = @import("ziglua");

const Lua = ziglua.Lua;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // First we specify what parameters our program can take.
    // We can use `parseParamsComptime` to parse a string into an array of `Param(Help)`
    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Display this help and exit.
        \\-v, --verbose          Print verbose output, useful for debugging
        \\<FILE> <COMMANDS>...
        \\
    );

    const Commands = enum { ln, repos };
    const parsers = comptime .{
        .FILE = clap.parsers.string,
        .COMMANDS = clap.parsers.enumeration(Commands),
    };

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, parsers, .{
        .diagnostic = &diag,
        .allocator = gpa.allocator(),
    }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0)
        std.debug.print("--help\n", .{});
    if (res.args.verbose != 0)
        std.debug.print("--verbose\n", .{});
    for (res.positionals) |pos|
        std.debug.print("{s}\n", .{pos});

    var lua = try Lua.init(allocator);
    defer lua.deinit();

    // NOTE: this is needed to "cast" the file name from a []const u8 to [:0]const u8 (which lua.doFile expects)
    const file_name = try std.fmt.allocPrintZ(allocator, "{s}", .{res.positionals[0]});
    defer allocator.free(file_name);

    // TODO: check if the file even exists before dumping it into lua.doFile
    // TODO: better error handling
    try lua.doFile(file_name);

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
