pub fn from_rgba(r: u8, g: u8, b: u8, a: u8) [4]f32 {
    return .{ @as(f32, @floatFromInt(r)) / 255.0, @as(f32, @floatFromInt(g)) / 255.0, @as(f32, @floatFromInt(b)) / 255.0, @as(f32, @floatFromInt(a)) / 255.0 };
}
