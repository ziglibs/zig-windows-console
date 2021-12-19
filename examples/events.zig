const std = @import("std");
const ansi = @import("ansi");
const zwc = @import("zwc");

pub fn main() !void {
    var con = try zwc.ConsoleApp.init();
    var stdout = std.io.getStdOut().writer();

    var before_cp = zwc.getCodepage();
    var before_input_mode = try con.getInputMode();
    var before_output_mode = try con.getOutputMode();

    try con.setInputMode(zwc.types.InputMode{
        .enable_extended_flags = true, // Does things... docs aren't very clear but do say they should be used with quickedit = false
        .enable_processed_input = false, // False disables Windows handling Control + C, we do that ourselves
        .enable_mouse_input = true, // Allows mouse events to be processed
        .enable_quick_edit_mode = false, // False disables auto drag selection
    });

    try con.setOutputMode(zwc.types.OutputMode{
        .enable_virtual_terminal_processing = true, // Enables ANSI sequences - this demo was originally a paint app but I didn't want unnecessary external deps to plague this simple example
    });

    defer {
        zwc.setCodepage(before_cp) catch {};
        con.setInputMode(before_input_mode) catch {};
        con.setOutputMode(before_output_mode) catch {};
    }

    try zwc.setCodepage(65001);
    try stdout.writeAll("Cool thing: I have UTF-8 support thanks to the 65001 codepage!\n");

    var sbi = try con.getScreenBufferInfo();
    var w: usize = 0;
    while (w < sbi.viewport_rect.right + 1) : (w += 1) {
        try stdout.writeAll("─");
    }
    try stdout.writeAll("\n");

    std.debug.print("Move your mouse around and type on your keyboard to see what I do!\n", .{});
    main: while (true) {
        var event = try con.getEvent();

        // NOTE: Mouse events don't work in Windows Terminal because Microsoft is slacking
        switch (event) {
            .key => |key| {
                if (key.key == .ascii and key.key.ascii == 3) break :main;

                std.debug.print("Key Event | key: {} | is down: {}\n", .{ key.key, key.is_down });
            },
            .mouse => |mouse| {
                std.debug.print("Mouse Event | abs: {} | in viewport: {}", .{ mouse.abs_coords, try con.viewportCoords(mouse.abs_coords, null) });
                if (mouse.mouse_flags.double_click) std.debug.print(" | double click", .{});
                if (mouse.mouse_flags.mouse_moved) std.debug.print(" | mouse moved", .{});
                if (mouse.mouse_flags.mouse_wheeled or mouse.mouse_flags.mouse_hwheeled) std.debug.print(" | mouse wheel: {}", .{mouse.mouse_scroll_direction.?});

                if (mouse.mouse_buttons.left_mouse_button) std.debug.print(" | left click", .{});
                if (mouse.mouse_buttons.middle_mouse_button) std.debug.print(" | middle click", .{});
                if (mouse.mouse_buttons.right_mouse_button) std.debug.print(" | right click", .{});

                std.debug.print("\n", .{});
            },
            .window_buffer_size => |wbz| {
                std.debug.print("Window Buffer Size | {}\n", .{wbz});
            },
            .menu => |menu| {
                std.debug.print("Menu Event | {}\n", .{menu});
            },
            .focus => |focused| {
                std.debug.print("Focused | {}\n", .{focused});
            },
        }
    }
}
