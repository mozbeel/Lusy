const std = @import("std");
const lexer = @import("lexer.zig");

const TokenType = lexer.TokenType;
const Token = lexer.Token;

pub const Expr = union(enum) {
    Number: []const u8,
    InfixOperation: struct {
        left: *Expr,
        op: TokenType,
        right: *Expr,
    },
};

pub const Parser = struct {
    tokens: []Token,
    index: usize = 0,

    currentExpr: Expr = .{ .Number = "0" },

    pub fn new(tokens: []Token) !Parser {
        return Parser{ .tokens = tokens };
    }

    pub fn run(self: *Parser) void {
        while (self.nextExpr()) {
            std.debug.print("CurrentExpr: {any}\n", .{self.currentExpr});
        }
    }

    pub fn deinit(self: *Parser) void {
        _ = self;
    }

    fn getTokenAtIndex(self: *Parser, index: usize) ?Token {
        if (self.tokens.len > index) {
            return self.tokens[index];
        }

        return null;
    }

    fn nextExpr(self: *Parser) bool {
        const tokenNullable = self.getTokenAtIndex(self.index);

        if (tokenNullable == null) {
            return false;
        }

        var expr: Expr = .{ .Number = "0" };

        const token = tokenNullable.?;
        switch (token.type) {
            .Illegal => {
                std.debug.print("Illegal Literal: {s}\n", .{token.literal});
                std.process.exit(1);
            },
            .Number => {
                expr = .{ .Number = token.literal };
                self.index += 1;
            },
            else => {
                self.index += 1;
            },
        }

        // If over the max index return .End
        self.currentExpr = expr;

        return true;
    }
};
