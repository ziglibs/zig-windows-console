const VirtualKey = @import("virtual_key.zig");

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
