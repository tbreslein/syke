const std = @import("std");
const clap = @import("clap");

pub const Commands = enum {
    repos,
    pkgs,
    config,
    sync,
};

pub const Args = struct {
    help: bool,
    verbose: bool,
    n_commands: usize,
    commands: []const Commands,
    file: [:0]const u8,
    gpa: std.heap.GeneralPurposeAllocator(.{}),

    pub fn init() !Args {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();

        const params = comptime clap.parseParamsComptime(
            \\-h, --help             Display this help and exit.
            \\-v, --verbose          Print verbose output, useful for debugging
            \\<FILE> <COMMANDS>...
            \\
        );

        const parsers = comptime .{
            .FILE = clap.parsers.string,
            .COMMANDS = clap.parsers.enumeration(Commands),
        };

        var diag = clap.Diagnostic{};
        var res = clap.parse(clap.Help, &params, parsers, .{
            .diagnostic = &diag,
            .allocator = allocator,
        }) catch |err| {
            diag.report(std.io.getStdErr().writer(), err) catch {};
            return err;
        };
        defer res.deinit();

        const help = res.args.help != 0;
        const verbose = res.args.verbose != 0;

        if (res.positionals.len == 0) {
            // TODO: throw error
        }

        // TODO: check if file exists
        // NOTE: this is needed to "cast" the file name from a []const u8 to [:0]const u8 (which lua.doFile expects)
        const file = try std.fmt.allocPrintZ(allocator, "{s}", .{res.positionals[0]});
        var n_commands = res.positionals.len - 1;
        var commands = try allocator.alloc(Commands, n_commands);
        if (n_commands == 0) {
            commands[0] = Commands.sync;
            n_commands = 1;
        } else {
            // TODO: iter through the remaining args and parse them to Commands
        }

        return Args{ .gpa = gpa, .help = help, .verbose = verbose, .file = file, .commands = commands, .n_commands = n_commands };
    }

    pub fn deinit(self: Args) void {
        var allocator = self.gpa.allocator();
        allocator.free(self.file);
        allocator.free(self.commands);
        self.gpa.deinit();
    }
};
