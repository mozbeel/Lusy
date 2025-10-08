//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const lexer = @import("lexer.zig");

const Lexer = lexer.Lexer;

pub const Lusy = struct {
    args: [][]const u8 = undefined,

    pub fn new(args: [][]const u8) Lusy {
        return Lusy{
            .args = args,
        };
    }

    pub fn run(self: *Lusy) void {
        if (self.args.len < 2) {
            std.debug.print("Usage: {s} <source_file>.lusy\n", .{self.args[0]});
        }
    }
};
