const std = @import("std");
const lusy = @import("lusy");

const Lusy = lusy.Lusy;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const raw_args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, raw_args);

    var args = try allocator.alloc([]const u8, raw_args.len);
    defer allocator.free(args);

    for (raw_args, 0..) |a, i| {
        args[i] = std.mem.sliceTo(a, 0); // remove null terminator
    }

    var instance = Lusy.new(args);
    instance.run();
}
