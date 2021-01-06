const c = @import("c/c.zig");
const vk = @import("c/vk.zig");
const std = @import("std");
const control_keys = @import("c/consts/control_keys.zig");

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
    shift_pressed: bool = false,

    pub fn fromUnsigned(u: u32) Self {
        var ck = Self{};
        
        inline for (std.meta.fields(Self)) |ck_field| {
            if (u & @field(control_keys, ck_field.name) == @field(control_keys, ck_field.name))
                @field(ck, ck_field.name) = true
            else
                @field(ck, ck_field.name) = false;
        }

        return ck;
    }
};

pub const KeyEvent = struct {
    key: Key,
    is_down: bool,
    control_keys: ControlKeys
};

pub const MouseEvent = struct {

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
                    .control_keys = ControlKeys.fromUnsigned(ir.Event.KeyEvent.dwControlKeyState)
                }};
            },
            c.MOUSE_EVENT => {
                return Self{.mouse = .{}};
            },
            else => std.debug.panic("Not implemented: {}!\n", .{ir.EventType})
        }
    }
};
