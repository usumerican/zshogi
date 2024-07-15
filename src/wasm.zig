const std = @import("std");
const tst = std.testing;
const builtin = @import("builtin");
const main = @import("main.zig");

const allocator = if (builtin.is_test) tst.allocator else std.heap.wasm_allocator;
var engine = main.Engine.init(allocator);

const Slice = packed struct {
    addr: usize,
    len: usize,

    fn ptr(self: @This()) [*]u8 {
        return @ptrFromInt(self.addr);
    }

    fn items(self: @This()) []u8 {
        return self.ptr()[0..self.len];
    }
};

export fn sliceInit(addr: usize, len: usize) Slice {
    return .{ .addr = addr, .len = len };
}

export fn sliceAddr(slice: Slice) usize {
    return slice.addr;
}

export fn sliceLen(slice: Slice) usize {
    return slice.len;
}

export fn sliceAlloc(len: usize) Slice {
    const items = allocator.alloc(u8, len) catch return sliceInit(0, 0);
    return sliceInit(@intFromPtr(items.ptr), items.len);
}

export fn sliceFree(slice: Slice) void {
    allocator.free(slice.items());
}

test "Slice" {
    const slice = sliceAlloc(10);
    defer sliceFree(slice);
    try tst.expect(0 != sliceAddr(slice));
    try tst.expectEqual(10, sliceLen(slice));
}

export fn run(slice: Slice) Slice {
    const items = engine.run(slice.items()) catch return sliceInit(0, 0);
    return sliceInit(@intFromPtr(items.ptr), items.len);
}

test "run" {
    const request = "usi";
    const request_slice = sliceAlloc(request.len);
    defer sliceFree(request_slice);
    @memcpy(request_slice.items(), request);
    const response_slice = run(request_slice);
    defer sliceFree(response_slice);
    try tst.expectStringEndsWith(response_slice.items(), "\n");
}
