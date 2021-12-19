const std = @import("std");
const testing = std.testing;

const c = @import("c/c.zig");
const windows = c.windows;
const utils = @import("utils.zig");
pub const types = @import("types.zig");
pub const Event = @import("events.zig").Event;

pub fn getCodepage() c_uint {
    return c.GetConsoleOutputCP();
}

pub fn setCodepage(codepage: c_uint) !void {
    if (c.SetConsoleOutputCP(codepage) == 0) {
        switch (windows.kernel32.GetLastError()) {
            else => |err| return windows.unexpectedError(err),
        }
    }
}

pub const ConsoleApp = struct {
    const Self = @This();

    stdin_handle: windows.HANDLE,
    stdout_handle: windows.HANDLE,

    pub fn init() !Self {
        return Self{ .stdin_handle = try windows.GetStdHandle(windows.STD_INPUT_HANDLE), .stdout_handle = try windows.GetStdHandle(windows.STD_OUTPUT_HANDLE) };
    }

    pub fn getInputMode(self: Self) !types.InputMode {
        var mode: windows.DWORD = undefined;
        if (c.GetConsoleMode(self.stdin_handle, &mode) == 0) {
            switch (windows.kernel32.GetLastError()) {
                else => |err| return windows.unexpectedError(err),
            }
        }
        return utils.fromUnsigned(types.InputMode, mode);
    }

    pub fn setInputMode(self: Self, mode: types.InputMode) !void {
        if (c.SetConsoleMode(self.stdin_handle, utils.toUnsigned(types.InputMode, mode)) == 0) {
            switch (windows.kernel32.GetLastError()) {
                else => |err| return windows.unexpectedError(err),
            }
        }
    }

    pub fn getOutputMode(self: Self) !types.OutputMode {
        var mode: windows.DWORD = undefined;
        if (c.GetConsoleMode(self.stdout_handle, &mode) == 0) {
            switch (windows.kernel32.GetLastError()) {
                else => |err| return windows.unexpectedError(err),
            }
        }
        return utils.fromUnsigned(types.OutputMode, mode);
    }

    pub fn setOutputMode(self: Self, mode: types.OutputMode) !void {
        if (c.SetConsoleMode(self.stdout_handle, utils.toUnsigned(types.OutputMode, mode)) == 0) {
            switch (windows.kernel32.GetLastError()) {
                else => |err| return windows.unexpectedError(err),
            }
        }
    }

    pub fn getEvent(self: Self) !Event {
        var event_count: u32 = 0;
        var input_record = std.mem.zeroes(c.INPUT_RECORD);

        if (c.ReadConsoleInputW(self.stdin_handle, &input_record, 1, &event_count) == 0) {
            switch (windows.kernel32.GetLastError()) {
                else => |err| return windows.unexpectedError(err),
            }
        }

        return Event.fromInputRecord(input_record);
    }

    pub fn viewportCoords(self: Self, coords: types.Coords, viewport_rect: ?types.Rect) !types.Coords {
        return types.Coords{ .x = coords.x, .y = coords.y - (viewport_rect orelse (try self.getScreenBufferInfo()).viewport_rect).top };
    }

    pub fn getScreenBufferInfo(self: Self) !types.ScreenBufferInfo {
        var bf = std.mem.zeroes(windows.CONSOLE_SCREEN_BUFFER_INFO);

        if (windows.kernel32.GetConsoleScreenBufferInfo(self.stdout_handle, &bf) == 0) {
            switch (windows.kernel32.GetLastError()) {
                else => |err| return windows.unexpectedError(err),
            }
        }

        return @bitCast(types.ScreenBufferInfo, bf);
    }
};
