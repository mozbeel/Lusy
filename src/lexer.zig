const std = @import("std");

/// TokenType defines the type of each token the lexer can produce.
pub const TokenType = enum {
    Illegal, // A token we don't know about
    Eof, // "End of File"

    // Literals
    Number, // 12345

    // Operators
    Plus, // +
    Minus, // -
    Star, // *
    Slash, // /
    Modulus, // %

    // Delimiters
    LParen, // (
    RParen, // )
};

/// Token represents a single unit of code. It has a type and a literal value.
pub const Token = struct {
    type: TokenType,
    literal: []const u8,
};

pub const Lexer = struct {
    content: []const u8,
    position: usize, // current position in input (points to current char)
    read_position: usize, // current reading position (after current char)
    ch: u8, // current char under examination
    tokens: std.ArrayList(Token),

    const allocator = std.heap.page_allocator;

    pub fn new(source_file_path: []const u8) !Lexer {
        const content = try getFileContent(source_file_path);
        var l = Lexer{
            .content = content,
            .position = 0,
            .read_position = 0,
            .ch = 0,
            .tokens = try std.ArrayList(Token).initCapacity(allocator, 250),
        };
        // Prime the lexer by reading the first character
        l.readChar();
        return l;
    }

    /// Reads the next character and advances our position in the input string.
    fn readChar(self: *Lexer) void {
        if (self.read_position >= self.content.len) {
            self.ch = 0; // 0 is ASCII for "NUL", signifies EOF
        } else {
            self.ch = self.content[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }

    /// Skips over any whitespace characters.
    fn skipWhitespace(self: *Lexer) void {
        while (std.ascii.isWhitespace(self.ch)) {
            self.readChar();
        }
    }

    /// Reads a multi-digit number.
    fn readNumber(self: *Lexer) []const u8 {
        const start_position = self.position;
        while (std.ascii.isDigit(self.ch)) {
            self.readChar();
        }
        return self.content[start_position..self.position];
    }

    /// The core function of the lexer. It examines the current character,
    /// creates a token, and advances the pointers.
    pub fn nextToken(self: *Lexer) Token {
        var tok: Token = undefined;

        self.skipWhitespace();

        var shouldReadChar = true;
        var shouldAppend = true;

        switch (self.ch) {
            '+' => tok = .{ .type = .Plus, .literal = self.content[self.position..self.read_position] },
            '-' => tok = .{ .type = .Minus, .literal = self.content[self.position..self.read_position] },
            '*' => tok = .{ .type = .Star, .literal = self.content[self.position..self.read_position] },
            '/' => tok = .{ .type = .Slash, .literal = self.content[self.position..self.read_position] },
            '(' => tok = .{ .type = .LParen, .literal = self.content[self.position..self.read_position] },
            ')' => tok = .{ .type = .RParen, .literal = self.content[self.position..self.read_position] },
            '%' => tok = .{ .type = .Modulus, .literal = self.content[self.position..self.read_position] },
            0 => {
                tok = .{ .type = .Eof, .literal = "" };
                shouldAppend = false;
            },
            else => {
                if (std.ascii.isDigit(self.ch)) {
                    // If it's a digit, read the whole number and return immediately
                    const literal = self.readNumber();
                    tok = .{ .type = .Number, .literal = literal };
                    shouldReadChar = false;
                } else {
                    // If we don't recognize the character, it's an Illegal token
                    tok = .{ .type = .Illegal, .literal = self.content[self.position..self.read_position] };
                }
            },
        }

        if (shouldAppend) {
            self.tokens.append(allocator, tok) catch {
                std.debug.print("Couldn't append token (internal error)!\n", .{});
            };
        }

        if (shouldReadChar) self.readChar();
        return tok;
    }

    fn getFileContent(source_file_path: []const u8) ![]const u8 {
        if (!doesFileExist(source_file_path)) {
            std.debug.print("File {s} does not exist!\n", .{source_file_path});
            std.process.exit(1);
        }
        var file = try std.fs.cwd().openFile(source_file_path, .{});
        defer file.close();

        const file_size = try file.getEndPos();
        const file_content = try allocator.alloc(u8, file_size);

        _ = try file.readAll(file_content);

        return file_content;
    }

    fn doesFileExist(source_file_path: []const u8) bool {
        std.fs.cwd().access(source_file_path, .{}) catch return false;
        return true;
    }

    /// The run method now loops through the input and prints all tokens.
    pub fn run(self: *Lexer) !void {
        std.debug.print("--- Tokens ---\n", .{});
        var token = self.nextToken();
        while (token.type != .Eof) {
            std.debug.print(".{{ .type = {any}, .literal = {s} }} \n", .{ token.type, token.literal });
            token = self.nextToken();
        }
        std.debug.print("--------------\n", .{});
    }

    pub fn deinit(self: *Lexer) void {
        self.tokens.deinit(allocator);
    }
};
