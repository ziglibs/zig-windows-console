const std = @import("std");

const c = @import("c/c.zig");
const utils = @import("utils.zig");
const types = @import("types.zig");

pub const Event = union(enum) {
    const Self = @This();

    key: types.KeyEvent,
    mouse: types.MouseEvent,
    window_buffer_size: types.Coords,
    menu: u32,
    focus: bool,

    pub fn fromInputRecord(ir: c.INPUT_RECORD) Self {
        switch (ir.EventType) {
            // NOTE: I'm unsure if this behavior is intentional or not but the KeyEvent.uChar union has two active fields at a time
            c.KEY_EVENT => {
                return Self{ .key = .{
                    .key = if (ir.Event.KeyEvent.uChar.AsciiChar == ir.Event.KeyEvent.uChar.UnicodeChar)
                        (if (ir.Event.KeyEvent.uChar.AsciiChar == 0)
                            (if (types.VirtualKey.fromValue(ir.Event.KeyEvent.wVirtualKeyCode)) |v|
                                types.Key{ .virtual_key = v }
                            else
                                types.Key{ .unknown = {} })
                        else
                            types.Key{ .ascii = ir.Event.KeyEvent.uChar.AsciiChar })
                    else
                        types.Key{ .unicode = ir.Event.KeyEvent.uChar.UnicodeChar },
                    .is_down = if (ir.Event.KeyEvent.bKeyDown == 0) false else true,
                    .control_keys = utils.fromUnsigned(types.ControlKeys, ir.Event.KeyEvent.dwControlKeyState),
                } };
            },
            c.MOUSE_EVENT => {
                var flags = utils.fromUnsigned(types.MouseFlags, ir.Event.MouseEvent.dwEventFlags);
                return Self{ .mouse = .{
                    .abs_coords = @bitCast(types.Coords, ir.Event.MouseEvent.dwMousePosition),
                    .mouse_buttons = utils.fromUnsigned(types.MouseButtons, ir.Event.MouseEvent.dwButtonState),
                    .mouse_flags = flags,
                    .mouse_scroll_direction = if (flags.mouse_wheeled)
                        (if (ir.Event.MouseEvent.dwButtonState & 0xFF000000 == 0xFF000000)
                            types.MouseScrollDirection.down
                        else
                            types.MouseScrollDirection.up)
                    else if (flags.mouse_hwheeled)
                        (if (ir.Event.MouseEvent.dwButtonState & 0xFF000000 == 0xFF000000)
                            types.MouseScrollDirection.left
                        else
                            types.MouseScrollDirection.right)
                    else
                        null,
                    .control_keys = utils.fromUnsigned(types.ControlKeys, ir.Event.MouseEvent.dwControlKeyState),
                } };
            },
            c.WINDOW_BUFFER_SIZE_EVENT => {
                return Self{ .window_buffer_size = @bitCast(types.Coords, ir.Event.WindowBufferSizeEvent.dwSize) };
            },
            c.MENU_EVENT => {
                return Self{ .menu = ir.Event.MenuEvent.dwCommandId };
            },
            c.FOCUS_EVENT => {
                return Self{ .focus = if (ir.Event.FocusEvent.bSetFocus == 0) false else true };
            },
            else => std.debug.panic("Not implemented: {}!\n", .{ir.EventType}),
        }
    }
};
