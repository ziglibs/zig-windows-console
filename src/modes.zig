const std = @import("std");
const utils = @import("utils.zig");
const input_modes = @import("c/consts/input_modes.zig");
const output_modes = @import("c/consts/output_modes.zig");

pub const InputMode = struct {
    const Self = @This();

    enable_echo_input: bool = true,
    enable_insert_mode: bool = true,
    enable_line_input: bool = true,
    enable_mouse_input: bool = true,
    enable_processed_input: bool = true,
    enable_quick_edit_mode: bool = true,
    enable_window_input: bool = false,
    enable_virtual_terminal_input: bool = false,
    enable_extended_flags: bool = true,

    pub fn toUnsigned(self: Self) u32 {
        return utils.toUnsigned(input_modes, Self, self);
    }

    pub fn fromUnsigned(m: u32) Self {
        return utils.fromUnsigned(input_modes, Self, m);
    }
};

pub const OutputMode = struct {
    const Self = @This();

    enable_processed_output: bool = true,
    enable_wrap_at_eol_output: bool = true,
    enable_virtual_terminal_processing: bool = false,
    disable_newline_auto_return: bool = false,
    enable_lvb_grid_worldwide: bool = false,

    pub fn toUnsigned(self: Self) u32 {
        return utils.toUnsigned(output_modes, Self, self);
    }

    pub fn fromUnsigned(m: u32) Self {
        return utils.fromUnsigned(output_modes, Self, m);
    }
};
