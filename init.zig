const std = @import("std");
const Io = std.Io;

const USAGE =
    \\ Usage: init
    \\
    \\ Options:
    \\    -f|--force: Overwrite exercises that already exist
    \\    -o|--output: Include the output directory.
    \\                 The output will be relative to the excercies directory.
    \\                 `./init-o day-1` generates files in ./exercises/day-1/
    \\                 ./exercises is the default directory
    \\
    \\
;

fn display_usage() void {
    std.debug.print(USAGE, .{});
}

const MetaEntry = struct {
    name: []const u8,
    template: []const u8,
};

const Meta = struct { kata: []MetaEntry };

const ScriptError = error{MissingArgument};

const meta_filename = "./meta.zon";
const output_dir = "./exercises/";
const template_dir = "./templates/";

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.arena.allocator();

    var argsIterator = init.minimal.args.iterate();
    var force: bool = false;
    var output: ?[]const u8 = null;

    while (argsIterator.next()) |arg| {
        if (std.mem.eql(u8, "-f", arg) or std.mem.eql(u8, "--force", arg)) {
            force = true;
        } else if (std.mem.eql(u8, "-h", arg) or std.mem.eql(u8, "--help", arg)) {
            display_usage();
            return;
        } else if (std.mem.eql(u8, "-o", arg) or std.mem.eql(u8, "--output", arg)) {
            output = argsIterator.next() orelse {
                std.debug.print("Missing argument for -o|--output\n", .{});
                return ScriptError.MissingArgument;
            };
        }
    }

    const meta_contents = try file_get_contents(io, allocator, meta_filename);
    const meta = try parse_meta_file(allocator, meta_contents);

    defer std.zon.parse.free(allocator, meta);

    const cwd = std.Io.Dir.cwd();

    var resolved_outdir: []const u8 = output_dir;
    if (output) |out| {
        resolved_outdir = try std.mem.concat(allocator, u8, &[_][]const u8{ output_dir, out, "/" });
    }

    cwd.createDir(io, resolved_outdir, .default_dir) catch |e| switch (e) {
        error.PathAlreadyExists => {},
        else => return e,
    };

    const out_dir = try cwd.openDir(io, resolved_outdir, .{});
    defer out_dir.close(io);

    for (meta.kata) |kata| {
        const template_path = try std.mem.concat(allocator, u8, &.{ template_dir[0..], kata.template[0..] });

        const template = try file_get_contents(io, allocator, template_path);

        const file: ?Io.File = out_dir.createFile(io, kata.name, .{ .exclusive = !force }) catch |e| switch (e) {
            error.PathAlreadyExists => null,
            else => return e,
        };

        if (file) |f| {
            errdefer f.close(io);

            var file_writer = f.writer(io, &.{});
            const writer = &file_writer.interface;

            _ = try writer.write(template);

            f.close(io);
        }
    }
}

fn parse_meta_file(allocator: std.mem.Allocator, contents: [:0]const u8) !Meta {
    var diagnostics: std.zon.parse.Diagnostics = .{};
    defer diagnostics.deinit(allocator);
    const meta = std.zon.parse.fromSliceAlloc(Meta, allocator, contents, &diagnostics, .{ .ignore_unknown_fields = true, .free_on_error = true }) catch |err| {
        std.debug.print("{f}\n", .{diagnostics});
        return err;
    };

    return meta;
}

fn file_get_contents(io: Io, allocator: std.mem.Allocator, filename: []const u8) ![:0]const u8 {
    const dir = std.Io.Dir.cwd();
    const file = try std.Io.Dir.openFile(dir, io, filename, .{});
    defer std.Io.File.close(file, io);

    const stat = try std.Io.File.stat(file, io);
    const length = stat.size;

    var file_reader = file.reader(io, &.{});
    const reader = &file_reader.interface;

    const buffer = try allocator.alloc(u8, length + 1);
    errdefer allocator.free(buffer);

    try std.Io.Reader.readSliceAll(reader, buffer[0..length]);
    buffer[length] = 0;

    return buffer[0..length :0];
}
