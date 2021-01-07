// Mouse buttons
// https://docs.microsoft.com/en-us/windows/console/mouse-event-record-str
pub const left_mouse_button = 0x0001;
pub const middle_mouse_button = 0x0004;
pub const right_mouse_button = 0x0002;

// ControlKeys
// https://docs.microsoft.com/en-us/windows/console/key-event-record-str
// [...$0.parentElement.children].map(_ => "pub const " + _.children[0].innerText.split(" ").map(_ => _.toLowerCase()).join(" = ")).join(";\n")+";\n"
pub const capslock_on = 0x0080;
pub const enhanced_key = 0x0100;
pub const left_alt_pressed = 0x0002;
pub const left_ctrl_pressed = 0x0008;
pub const numlock_on = 0x0020;
pub const right_alt_pressed = 0x0001;
pub const right_ctrl_pressed = 0x0004;
pub const scrolllock_on = 0x0040;
pub const shift_pressed = 0x0010;

// Mouse event flags
// https://docs.microsoft.com/en-us/windows/console/mouse-event-record-str
pub const double_click = 0x0002;
pub const mouse_hwheeled = 0x0008;
pub const mouse_moved = 0x0001;
pub const mouse_wheeled = 0x0004;

// Input modes
pub const enable_processed_input = 0x0001;
pub const enable_line_input = 0x0002;
pub const enable_echo_input = 0x0004;
pub const enable_window_input = 0x0008;
pub const enable_mouse_input = 0x0010;
pub const enable_insert_mode = 0x0020;
pub const enable_quick_edit_mode = 0x0040;
pub const enable_extended_flags = 0x0080;
pub const enable_auto_position = 0x0100;
pub const enable_virtual_terminal_input = 0x0200;

// Output modes
pub const enable_processed_output = 0x0001;
pub const enable_wrap_at_eol_output = 0x0002;
pub const enable_virtual_terminal_processing = 0x0004;
pub const disable_newline_auto_return = 0x0008;
pub const enable_lvb_grid_worldwide = 0x0010;
