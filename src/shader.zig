const gl = @import("gl");

const std = @import("std");
const read = std.fs.Dir.readFile;

fn compile_shader(path: []const u8, t: gl.GLenum) u32 {
    const id = gl.createShader(t);
    var buf: [2048]u8 = .{0} ** 2048;
    if (read(std.fs.cwd(), path, &buf)) |ptr| {
        gl.shaderSource(id, 1, &ptr.ptr, null);
        gl.compileShader(id);
    } else |err| {
        std.debug.print("error reading shader type {d} {s}: {}", .{ t, path, err });
    }
    return id;
}

pub const ShaderType = enum {
    vertex,
    geometry,
    fragment,
};

pub const program = struct {
    id: u32,

    const Self = @This();

    pub fn new() Self {
        return .{ .id = gl.createProgram() };
    }

    pub fn attach(self: Self, path: []const u8, shader: ShaderType) Self {
        const shader_id = switch (shader) {
            .vertex => compile_shader(path, gl.VERTEX_SHADER),
            .geometry => compile_shader(path, gl.GEOMETRY_SHADER),
            .fragment => compile_shader(path, gl.FRAGMENT_SHADER),
        };
        gl.attachShader(self.id, shader_id);
        return self;
    }

    pub fn link(self: Self) void {
        gl.linkProgram(self.id);
    }

    pub fn delete(self: Self) void {
        gl.deleteProgram(self.id);
    }

    pub fn use(self: Self) void {
        gl.useProgram(self.id);
    }
};
