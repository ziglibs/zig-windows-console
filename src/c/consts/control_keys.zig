// https://docs.microsoft.com/en-us/windows/console/key-event-record-str
// [...$0.parentElement.children].map(_ => "pub const " + _.children[0].innerText.split(" ").join(" = ")).join(";\n")+";\n"

pub const capslock_on = 0x0080;
pub const enhanced_key = 0x0100;
pub const left_alt_pressed = 0x0002;
pub const left_ctrl_pressed = 0x0008;
pub const numlock_on = 0x0020;
pub const right_alt_pressed = 0x0001;
pub const right_ctrl_pressed = 0x0004;
pub const scrolllock_on = 0x0040;
pub const shift_pressed = 0x0010;
