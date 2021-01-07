const std = @import("std");

const Self = @This();

alias: []const u8,
value: u16,

const virtual_keys = comptime v: {
    @setEvalBranchQuota(100000);

    const list = @embedFile("c/vk_list");
    
    var i: usize = 0;
    var vks = [_]Self{std.mem.zeroes(Self)}**(std.mem.count(u8, list, "\n")+1);
    var lines = std.mem.split(list, "\n");

    while (lines.next()) |line| {
        var line_vals = std.mem.split(line, " ");

        var alias = line_vals.next().?;
        var value = std.mem.trim(u8, line_vals.next().?, &std.ascii.spaces);
        vks[i] = .{.alias = alias, .value = try std.fmt.parseInt(u16, value, 10)};

        i += 1;
    }

    break :v &vks;
};

pub fn fromSymbolic(symbol: []const u8) ?Self {
    for (virtual_keys) |v| {
        if (std.mem.eql(u8, v.alias, symbol)) return v;
    }
    return null;
}

pub fn fromValue(value: u16) ?Self {
    for (virtual_keys) |v| {
        if (value == v.value) return v;
    }
    return null;
}
