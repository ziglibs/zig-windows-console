const std = @import("std");
const testing = std.testing;

const c = @import("c/c.zig");

pub usingnamespace @import("types.zig");
pub usingnamespace @import("modes.zig");
pub usingnamespace @import("events.zig");

const utils = @import("utils.zig");
pub const VirtualKey = @import("virtual_key.zig");

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
        return utils.fromUnsigned(InputMode, mode);
    }

    pub fn setInputMode(self: Self, mode: InputMode) !void {
        if (c.SetConsoleMode(self.stdin_handle, utils.toUnsigned(InputMode, mode)) == 0) {
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
        return utils.fromUnsigned(OutputMode, mode);
    }

    pub fn setOutputMode(self: Self, mode: OutputMode) !void {
        if (c.SetConsoleMode(self.stdout_handle, utils.toUnsigned(OutputMode, mode)) == 0) {
            switch (c.kernel32.GetLastError()) {
                else => |err| return c.unexpectedError(err),
            }
        }
    }

    pub fn getEvent(self: Self) !Event {
        var events: u32 = 0;
        var input_record = std.mem.zeroes(c.INPUT_RECORD);

        if (c.ReadConsoleInputW(self.stdin_handle, &input_record, 1, &events) == 0) {
            switch (c.kernel32.GetLastError()) {
                else => |err| return c.unexpectedError(err),
            }
        }

        return Event.fromInputRecord(input_record);
    }

    pub fn viewportCoords(self: Self, coords: Coords, viewport_rect: ?Rect) !Coords {
        return Coords{.x = coords.x, .y = coords.y - (viewport_rect orelse (try self.getScreenBufferInfo()).viewport_rect).top};
    }

    pub fn getScreenBufferInfo(self: Self) !ScreenBufferInfo {
        var bf = std.mem.zeroes(c.CONSOLE_SCREEN_BUFFER_INFO);
    
        if (c.kernel32.GetConsoleScreenBufferInfo(self.stdout_handle, &bf) == 0) {
            switch (c.kernel32.GetLastError()) {
                else => |err| return c.unexpectedError(err),
            }
        }

        return @bitCast(ScreenBufferInfo, bf);
    }

    pub fn writeW(self: Self, buf: []u16) !void {
        if (c.WriteConsoleW(self.stdout_handle, buf.ptr, @intCast(u32, buf.len), null, null) == 0) {
            switch (c.kernel32.GetLastError()) {
                else => |err| return c.unexpectedError(err),
            }
        }
    }
};
