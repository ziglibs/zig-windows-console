const std = @import("std");
const ansi = @import("ansi");
const zwincon = @import("zwincon");
const c = zwincon.c;

pub fn main() !void {
    var con = try zwincon.ConsoleApp.init();
    var before_input_mode = try con.getInputMode();
    var before_output_mode = try con.getOutputMode();

    try con.setInputMode(zwincon.InputMode{
        .enable_extended_flags = true, // Does things... docs aren't very clear but do say they should be used with quickedit = false
        .enable_processed_input = false, // False disables Windows handling Control + C, we do that ourselves
        .enable_mouse_input = true, // Allows mouse events to be processed
        .enable_quick_edit_mode = false // False disables auto drag selection
    });

    try con.setOutputMode(zwincon.OutputMode{
        .enable_virtual_terminal_processing = true, // Enables ANSI sequences - this demo was originally a paint app but I didn't want unnecessary external deps to plague this simple example
    });

    defer {
        con.setInputMode(before_input_mode) catch {};
        con.setOutputMode(before_output_mode) catch {};
    }

    main: while (true) {
        var ir = try con.getInputRecord();

        switch (ir.EventType) {
            c.KEY_EVENT => {
                // Exit on Control + C
                if (ir.Event.KeyEvent.uChar.AsciiChar == 3) break :main;

                std.debug.print("KEY_EVENT | ascii key: {} ({c}) | virtual key: {} ({}) | is down: {}\n", .{
                    ir.Event.KeyEvent.uChar.AsciiChar, ir.Event.KeyEvent.uChar.AsciiChar, ir.Event.KeyEvent.wVirtualKeyCode, if (zwincon.vk.fromValue(ir.Event.KeyEvent.wVirtualKeyCode)) |v| v.alias else "Unknown", ir.Event.KeyEvent.bKeyDown
                });
            },
            // NOTE: Mouse events don't work in Windows Terminal because Microsoft is slacking
            c.MOUSE_EVENT => {
                // NOTE: The screen buffer has a `dwCursorPosition` - this is not the same thing as `dwMousePosition`.
                // The former is the position of the caret while the latter is the position of the mouse pointer.
                var screen_buf = try con.getScreenBufferInfo();
                var mouse_event = ir.Event.MouseEvent;

                var relative_x = mouse_event.dwMousePosition.X;
                var relative_y = mouse_event.dwMousePosition.Y - screen_buf.srWindow.Top; // dwMousePosition's Y is absolute (from the top of the console), this makes it relative to the viewport
                
                std.debug.print("MOUSE_EVENT | location: {} | location in viewport: {} {} | buttons: {}\n", .{
                    ir.Event.MouseEvent.dwMousePosition, relative_x, relative_y, ir.Event.MouseEvent.dwButtonState
                });
            },
            else => {}
        }
    }
}
