//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;
const Parser = @import("parser.zig").Parser;

pub const Lusy = struct {
    args: [][]const u8 = undefined,

    pub fn new(args: [][]const u8) Lusy {
        return Lusy{
            .args = args,
        };
    }

    pub fn run(self: *Lusy) !void {
        if (self.args.len < 2) {
            std.debug.print("Usage: {s} <source_file>.lusy\n", .{self.args[0]});
            std.process.exit(1);
        }

        var lexer = try Lexer.new(self.args[1]);
        defer lexer.deinit();
        try lexer.run();

        var parser = try Parser.new(lexer.tokens.items);
        defer parser.deinit();
        try parser.run();
    }
};
