const std = @import("std");

pub const targets = @import("subcommands/targets.zig");
pub const cvtres = @import("subcommands/cvtres.zig");

test {
    _ = std.testing.refAllDecls(@This());
}
