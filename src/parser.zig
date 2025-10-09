const std = @import("std");
const lexer = @import("lexer.zig");

const TokenType = lexer.TokenType;
const Token = lexer.Token;

pub const ExprType = union(enum) {
    Number: []const u8,
    InfixOperation: struct {
        left: *Expr,
        op: TokenType,
        right: *Expr,
    },
    Plus,
    Minus,
    Star,
    Slash,
    Modulus,

    LParen,
    RParen,
};

pub const Expr = struct {
    expr: ExprType,
    left: *Expr = undefined,
    right: *Expr = undefined,

    pub fn toZigString(self: *Expr, allocator: std.mem.Allocator) ![]const u8 {
        return switch (self.*.expr) {
            .Number => |num| try std.fmt.allocPrint(allocator, ".{{ .expr = {{ .Number = \"{s}\" }} }}", .{num}),
            .InfixOperation => |op| try std.fmt.allocPrint(
                allocator,
                ".{{ .expr = {{ .InfixOperation = .{{ .left = 0x{x}, .op = .{s}, .right = 0x{x} }} }} }}",
                .{ @intFromPtr(op.left), @tagName(op.op), @intFromPtr(op.right) },
            ),
            .Plus => ".{{ .expr = .Plus }}",
            .Minus => ".{{ .expr = .Minus }}",
            .Star => ".{{ .expr = .Star }}",
            .Slash => ".{{ .expr = .Slash }}",
            .Modulus => ".{{ .expr = .Modulus }}",
            .LParen => ".{{ .expr = .LParen }}",
            .RParen => ".{{ .expr = .RParen }}",
        };
    }
};

pub const Parser = struct {
    tokens: []Token,
    index: usize = 0,

    currentExpr: Expr = .{ .expr = .{ .Number = "0" } },

    expressions: std.ArrayList(Expr),

    const allocator = std.heap.page_allocator;

    pub fn new(tokens: []Token) !Parser {
        return Parser{
            .tokens = tokens,
            .expressions = try std.ArrayList(Expr).initCapacity(allocator, 250),
        };
    }

    pub fn run(self: *Parser) !void {
        while (self.nextExpr()) {
            std.debug.print("CurrentExpr: {s}\n", .{try self.currentExpr.toZigString(allocator)});
        }
    }

    pub fn deinit(self: *Parser) void {
        self.expressions.deinit(allocator);
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

        var expr: Expr = .{ .expr = .{ .Number = "0" } };

        const token = tokenNullable.?;
        switch (token.type) {
            .Illegal => {
                std.debug.print("Illegal Literal: {s}\n", .{token.literal});
                std.process.exit(1);
            },
            .Number => {
                expr = .{ .expr = .{ .Number = token.literal } };
            },
            .Plus => {
                expr = .{ .expr = .Plus };
            },
            .Minus => {
                expr = .{ .expr = .Minus };
            },
            .Star => {
                expr = .{ .expr = .Star };
            },
            .Slash => {
                expr = .{ .expr = .Slash };
            },
            .Modulus => {
                expr = .{ .expr = .Modulus };
            },
            .LParen => {
                expr = .{ .expr = .LParen };
            },
            .RParen => {
                expr = .{ .expr = .RParen };
            },
            .Eof => unreachable,
        }

        // If over the max index return .End
        self.currentExpr = expr;
        self.index += 1;

        self.expressions.append(allocator, expr) catch {
            std.debug.print("Couldn't append to expressions list (internal error)!\n", .{});
            std.process.exit(1);
        };

        return true;
    }
};
