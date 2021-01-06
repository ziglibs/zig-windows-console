const std = @import("std");

pub const VK = struct {
    alias: []const u8,
    value: u16
};

pub const virtual_keys = comptime v: {
    @setEvalBranchQuota(100000);

    const list = @embedFile("vk_list");
    
    var i: usize = 0;
    var vks = [_]VK{std.mem.zeroes(VK)}**(std.mem.count(u8, list, "\n")+1);
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

pub fn fromAlias(alias: []const u8) ?VK {
    for (virtual_keys) |v| {
        if (std.mem.eql(u8, v.alias, alias)) return v;
    }
    return null;
}

pub fn fromValue(value: u16) ?VK {
    for (virtual_keys) |v| {
        if (value == v.value) return v;
    }
    return null;
}
