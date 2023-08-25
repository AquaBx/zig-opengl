const std = @import("std");
const gl = @import("gl");
const zlm = @import("zlm");

const read = std.fs.Dir.readFile;

fn compile_shader(path: []const u8, t: gl.GLenum) u32 {
    const id = gl.createShader(t);
    var buf: [2048]u8 = .{0} ** 2048;
    if (read(std.fs.cwd(), path, &buf)) |ptr| {
        gl.shaderSource(id, 1, &ptr.ptr, null);
        gl.compileShader(id);
    } else |err| {
        std.debug.print("error reading shader type {d} {s}: {any}", .{ t, path, err });
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
    uniforms: std.StringHashMap(u32),

    const Self = @This();

    pub fn new() Self {
        return .{
            .id = gl.createProgram(),
            .uniforms = std.StringHashMap(u32).init(std.heap.page_allocator),
        };
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

    pub fn register_uniform(self: *Self, name: []const u8) *Self {
        const loc = gl.getUniformLocation(self.id, name.ptr);
        if (loc < 0) {
            std.debug.print("uniform {s} is not in shader {d}\n", .{ name, self.id });
            return self;
        }
        self.uniforms.put(name, @bitCast(loc)) catch |err| {
            std.debug.print("error creating new uniform {s} for shader {d}: {any}\n", .{ name, self.id, err });
        };
        return self;
    }

    pub fn set_uniform_float(self: *Self, uniform: []const u8, x: f32) *Self {
        if (self.uniforms.get(uniform)) |location| {
            gl.uniform1f(@bitCast(location), x);
        }
        return self;
    }

    pub fn set_uniform_float2(self: *Self, uniform: []const u8, x: f32, y: f32) *Self {
        if (self.uniforms.get(uniform)) |location| {
            gl.uniform2f(@bitCast(location), x, y);
        }
        return self;
    }

    pub fn set_uniform_float3(self: *Self, uniform: []const u8, x: f32, y: f32, z: f32) *Self {
        if (self.uniforms.get(uniform)) |location| {
            gl.uniform3f(@bitCast(location), x, y, z);
        }
        return self;
    }

    pub fn set_uniform_float4(self: *Self, uniform: []const u8, x: f32, y: f32, z: f32, w: f32) *Self {
        if (self.uniforms.get(uniform)) |location| {
            gl.uniform4f(@bitCast(location), x, y, z, w);
        }
        return self;
    }

    pub fn set_uniform_mat4x4(self: *Self, uniform: []const u8, mat4: *const zlm.Mat4) *Self {
        if (self.uniforms.get(uniform)) |location| {
            gl.uniformMatrix4fv(@bitCast(location), 1, 0, @ptrCast(&mat4.fields));
        }
        return self;
    }
};
