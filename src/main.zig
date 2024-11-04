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
        \\-n, --number <INT>     An option parameter, which takes a value.
        \\-a, --answer <ANSWER>  An option parameter which takes an enum.
        \\-s, --string <STR>...  An option parameter which can be specified multiple times.
        \\<FILE>...
        \\
    );

    // Declare our own parsers which are used to map the argument strings to other
    // types.
    const YesNo = enum { yes, no };
    const parsers = comptime .{
        .STR = clap.parsers.string,
        .FILE = clap.parsers.string,
        .INT = clap.parsers.int(usize, 10),
        .ANSWER = clap.parsers.enumeration(YesNo),
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
    if (res.args.number) |n|
        std.debug.print("--number = {}\n", .{n});
    if (res.args.answer) |a|
        std.debug.print("--answer = {s}\n", .{@tagName(a)});
    for (res.args.string) |s|
        std.debug.print("--string = {s}\n", .{s});
    for (res.positionals) |pos|
        std.debug.print("{s}\n", .{pos});

    var lua = try Lua.init(allocator);
    defer lua.deinit();

    lua.pushInteger(42);
    std.debug.print("{}\n", .{try lua.toInteger(1)});
}
