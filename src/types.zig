const std = @import("std");

const virtual_keys = comptime v: {
    @setEvalBranchQuota(100000);

    const list = @embedFile("c/vk_list");
        
    var i: usize = 0;
    var vks = [_]VirtualKey{std.mem.zeroes(VirtualKey)}**(std.mem.count(u8, list, "\n")+1);
    var lines = std.mem.split(list, "\n");

    while (lines.next()) |line| {
        var line_vals = std.mem.split(line, " ");

        var symbol = line_vals.next().?;
        var value = std.mem.trim(u8, line_vals.next().?, &std.ascii.spaces);
        vks[i] = .{.symbol = symbol, .value = try std.fmt.parseInt(u16, value, 10)};

        i += 1;
    }

    break :v &vks;
};

pub const VirtualKey = struct {
    const Self = @This();

    symbol: []const u8,
    value: u16,

    pub fn fromSymbolic(symbol: []const u8) ?Self {
        for (virtual_keys) |v| {
            if (std.mem.eql(u8, v.symbol, symbol)) return v;
        }
        return null;
    }

    pub fn fromValue(value: u16) ?Self {
        for (virtual_keys) |v| {
            if (value == v.value) return v;
        }
        return null;
    }

    pub fn is(self: Self, symbol: []const u8) bool {
        return std.ascii.eqlIgnoreCase(self.symbol, symbol);
    }
};

pub const Coords = struct {
    x: i16,
    y: i16
};

pub const Rect = struct {
    left: i16,
    top: i16,
    right: i16,
    bottom: i16
};

pub const ScreenBufferInfo = struct {
    size: Coords,
    cursor_position: Coords,
    attributes: u16,
    viewport_rect: Rect,
    max_window_size: Coords,
};

pub const InputMode = struct {
    enable_echo_input: bool = true,
    enable_insert_mode: bool = true,
    enable_line_input: bool = true,
    enable_mouse_input: bool = true,
    enable_processed_input: bool = true,
    enable_quick_edit_mode: bool = true,
    enable_window_input: bool = false,
    enable_virtual_terminal_input: bool = false,
    enable_extended_flags: bool = true,
};

pub const OutputMode = struct {
    enable_processed_output: bool = true,
    enable_wrap_at_eol_output: bool = true,
    enable_virtual_terminal_processing: bool = false,
    disable_newline_auto_return: bool = false,
    enable_lvb_grid_worldwide: bool = false,
};

pub const Key = union(enum) {
    ascii: u8,
    unicode: u16,
    virtual_key: VirtualKey,
    unknown: void
};

pub const ControlKeys = struct {
    capslock_on: bool = false,
    enhanced_key: bool = false,
    left_alt_pressed: bool = false,
    left_ctrl_pressed: bool = false,
    numlock_on: bool = false,
    right_alt_pressed: bool = false,
    right_ctrl_pressed: bool = false,
    scrolllock_on: bool = false,
    shift_pressed: bool = false
};

pub const KeyEvent = struct {
    key: Key,
    is_down: bool,
    control_keys: ControlKeys
};

pub const MouseButtons = struct {
    left_mouse_button: bool = false,
    middle_mouse_button: bool = false,
    right_mouse_button: bool = false
};

pub const MouseFlags = struct {
    double_click: bool = false,
    mouse_hwheeled: bool = false,
    mouse_moved: bool = false,
    mouse_wheeled: bool = false
};

pub const MouseScrollDirection = enum {
    up,
    down,
    left,
    right
};

pub const MouseEvent = struct {
    abs_coords: Coords,
    mouse_buttons: MouseButtons,
    mouse_flags: MouseFlags,
    mouse_scroll_direction: ?MouseScrollDirection,
    control_keys: ControlKeys
};
