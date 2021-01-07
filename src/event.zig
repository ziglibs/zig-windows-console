const c = @import("c/c.zig");
const vk = @import("c/vk.zig");
const std = @import("std");
const utils = @import("utils.zig");

pub const Coords = struct {
    x: i16,
    y: i16
};

pub const Key = union(enum) {
    ascii: u8,
    unicode: u16,
    virtual_key: vk.VK,
    unknown: void
};

pub const ControlKeys = struct {
    const Self = @This();

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
    const Self = @This();

    left_mouse_button: bool = false,
    middle_mouse_button: bool = false,
    right_mouse_button: bool = false
};

pub const MouseEvent = struct {
    abs_coords: Coords,
    mouse_buttons: MouseButtons,
    control_keys: ControlKeys
};

pub const Event = union(enum) {
    const Self = @This();

    key: KeyEvent,
    mouse: MouseEvent,

    pub fn fromInputRecord(ir: c.INPUT_RECORD) Self {
        switch (ir.EventType) {
            // NOTE: I'm unsure if this behavior is intentional or not but the KeyEvent.uChar union has two active fields at a time
            c.KEY_EVENT => {
                return Self{.key = .{
                    .key =
                        if (ir.Event.KeyEvent.uChar.AsciiChar == ir.Event.KeyEvent.uChar.UnicodeChar)
                            (if (ir.Event.KeyEvent.uChar.AsciiChar == 0)
                                (if (vk.fromValue(ir.Event.KeyEvent.wVirtualKeyCode)) |v| Key{ .virtual_key = v } else Key{ .unknown = {} } )
                            else Key{ .ascii = ir.Event.KeyEvent.uChar.AsciiChar })
                        else Key{ .unicode = ir.Event.KeyEvent.uChar.UnicodeChar },
                    .is_down = if (ir.Event.KeyEvent.bKeyDown == 0) false else true,
                    .control_keys = utils.fromUnsigned(ControlKeys, ir.Event.KeyEvent.dwControlKeyState)
                }};
            },
            c.MOUSE_EVENT => {
                return Self{.mouse =. {
                    .abs_coords = @bitCast(Coords, ir.Event.MouseEvent.dwMousePosition),
                    .mouse_buttons = utils.fromUnsigned(MouseButtons, ir.Event.MouseEvent.dwButtonState),
                    .control_keys = utils.fromUnsigned(ControlKeys, ir.Event.MouseEvent.dwControlKeyState)
                }};
            },
            else => std.debug.panic("Not implemented: {}!\n", .{ir.EventType})
        }
    }
};
