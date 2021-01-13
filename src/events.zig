const std = @import("std");

const c = @import("c/c.zig");

const utils = @import("utils.zig");
const VirtualKey = @import("virtual_key.zig");

usingnamespace @import("types.zig");

pub const Event = union(enum) {
    const Self = @This();

    key: KeyEvent,
    mouse: MouseEvent,
    window_buffer_size: Coords,
    menu: u32,
    focus: bool,

    pub fn fromInputRecord(ir: c.INPUT_RECORD) Self {
        switch (ir.EventType) {
            // NOTE: I'm unsure if this behavior is intentional or not but the KeyEvent.uChar union has two active fields at a time
            c.KEY_EVENT => {
                return Self{.key = .{
                    .key =
                        if (ir.Event.KeyEvent.uChar.AsciiChar == ir.Event.KeyEvent.uChar.UnicodeChar)
                            (if (ir.Event.KeyEvent.uChar.AsciiChar == 0)
                                (if (VirtualKey.fromValue(ir.Event.KeyEvent.wVirtualKeyCode)) |v| Key{ .virtual_key = v } else Key{ .unknown = {} } )
                            else Key{ .ascii = ir.Event.KeyEvent.uChar.AsciiChar })
                        else Key{ .unicode = ir.Event.KeyEvent.uChar.UnicodeChar },
                    .is_down = if (ir.Event.KeyEvent.bKeyDown == 0) false else true,
                    .control_keys = utils.fromUnsigned(ControlKeys, ir.Event.KeyEvent.dwControlKeyState)
                }};
            },
            c.MOUSE_EVENT => {
                var flags = utils.fromUnsigned(MouseFlags, ir.Event.MouseEvent.dwEventFlags);
                return Self{.mouse =. {
                    .abs_coords = @bitCast(Coords, ir.Event.MouseEvent.dwMousePosition),
                    .mouse_buttons = utils.fromUnsigned(MouseButtons, ir.Event.MouseEvent.dwButtonState),
                    .mouse_flags = flags,
                    .mouse_scroll_direction = if (flags.mouse_wheeled) (
                        if (ir.Event.MouseEvent.dwButtonState & 0xFF000000 == 0xFF000000) MouseScrollDirection.down else MouseScrollDirection.up
                    ) else if (flags.mouse_hwheeled) (
                        if (ir.Event.MouseEvent.dwButtonState & 0xFF000000 == 0xFF000000) MouseScrollDirection.right else MouseScrollDirection.left
                    ) else null,
                    .control_keys = utils.fromUnsigned(ControlKeys, ir.Event.MouseEvent.dwControlKeyState)
                }};
            },
            c.WINDOW_BUFFER_SIZE_EVENT => {
                return Self{.window_buffer_size = @bitCast(Coords, ir.Event.WindowBufferSizeEvent.dwSize)};
            },
            c.MENU_EVENT => {
                return Self{.menu = ir.Event.MenuEvent.dwCommandId};
            },
            c.FOCUS_EVENT => {
                return Self{.focus = if (ir.Event.FocusEvent.bSetFocus == 0) false else true};
            },
            else => std.debug.panic("Not implemented: {}!\n", .{ir.EventType})
        }
    }
};
