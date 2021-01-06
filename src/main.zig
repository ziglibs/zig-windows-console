pub const c = @import("c/c.zig");
pub const vk = @import("c/vk.zig");
const std = @import("std");
const testing = std.testing;

pub usingnamespace @import("modes.zig");
pub usingnamespace @import("event.zig");

pub const ConsoleApp = struct {
    const Self = @This();

    stdin_handle: c.HANDLE,
    stdout_handle: c.HANDLE,

    pub fn init() !Self {
        return Self{
            .stdin_handle = try c.GetStdHandle(c.STD_INPUT_HANDLE),
            .stdout_handle = try c.GetStdHandle(c.STD_OUTPUT_HANDLE)
        };
    }

    pub fn getInputMode(self: Self) !InputMode {
        var mode: c.DWORD = undefined;
        if (c.GetConsoleMode(self.stdin_handle, &mode) == 0) {
            switch (c.kernel32.GetLastError()) {
                else => |err| return c.unexpectedError(err),
            }
        }
        return InputMode.fromUnsigned(mode);
    }

    pub fn setInputMode(self: Self, mode: InputMode) !void {
        if (c.SetConsoleMode(self.stdin_handle, mode.toUnsigned()) == 0) {
            switch (c.kernel32.GetLastError()) {
                else => |err| return c.unexpectedError(err),
            }
        }
    }

    pub fn getOutputMode(self: Self) !OutputMode {
        var mode: c.DWORD = undefined;
        if (c.GetConsoleMode(self.stdout_handle, &mode) == 0) {
            switch (c.kernel32.GetLastError()) {
                else => |err| return c.unexpectedError(err),
            }
        }
        return OutputMode.fromUnsigned(mode);
    }

    pub fn setOutputMode(self: Self, mode: OutputMode) !void {
        if (c.SetConsoleMode(self.stdout_handle, mode.toUnsigned()) == 0) {
            switch (c.kernel32.GetLastError()) {
                else => |err| return c.unexpectedError(err),
            }
        }
    }

    /// NOTE: Please don't directly use this - instead, use `getEvent`!
    pub fn getInputRecord(self: Self) !c.INPUT_RECORD {
        var events: u32 = 0;
        var input_record = std.mem.zeroes(c.INPUT_RECORD);

        if (c.ReadConsoleInputW(self.stdin_handle, &input_record, 1, &events) == 0) {
            switch (c.kernel32.GetLastError()) {
                else => |err| return c.unexpectedError(err),
            }
        }

        return input_record;
    }

    pub fn getEvent(self: Self) !Event {
        return Event.fromInputRecord(try self.getInputRecord());
    }

    pub fn getScreenBufferInfo(self: Self) !c.CONSOLE_SCREEN_BUFFER_INFO {
        var bf = std.mem.zeroes(c.CONSOLE_SCREEN_BUFFER_INFO);
    
        if (c.kernel32.GetConsoleScreenBufferInfo(self.stdout_handle, &bf) == 0) {
            switch (c.kernel32.GetLastError()) {
                else => |err| return c.unexpectedError(err),
            }
        }

        return bf;
    }
};
