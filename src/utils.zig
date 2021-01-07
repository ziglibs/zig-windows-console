const std = @import("std");

pub fn loWord(x: u32) u32 {
    return @truncate(u16, x);
}

pub fn hiWord(x: u32) u32 {
    return @truncate(u16, x >> 32);
}

pub fn toUnsigned(comptime constants: type, T: type, t: T) u32 {
    var unsigned: u32 = 0;

    inline for (std.meta.fields(T)) |field| {
        if (@field(t, field.name) == true)
            unsigned = unsigned | @field(constants, field.name);
    }

    return unsigned;
}

pub fn fromUnsigned(comptime constants: type, T: type, unsigned: u32) T {
    var t = T{};

    inline for (std.meta.fields(T)) |field| {
        if (unsigned & @field(constants, field.name) == @field(constants, field.name))
            @field(t, field.name) = true
        else
            @field(t, field.name) = false;
    }

    return t;
}
