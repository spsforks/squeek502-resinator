const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len <= 1) {
        std.debug.print("usage: {s} <filepath>\n", .{args[0]});
    }

    const filepath = args[1];

    var file = try std.fs.cwd().openFile(filepath, .{ .mode = .read_write });
    defer file.close();

    var buf = try std.ArrayList(u8).initCapacity(allocator, try file.getEndPos());
    defer buf.deinit();

    try utils.stripAndFixupCoff(allocator, file.reader(), buf.writer(), .{});

    try file.seekTo(0);
    try file.writeAll(buf.items);
    try file.setEndPos(buf.items.len);
}
