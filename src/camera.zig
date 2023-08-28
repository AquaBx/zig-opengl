const std = @import("std");
const zlm = @import("zlm");
const glfw = @import("mach-glfw");

fn view(from: [2]f32) zlm.Mat4 {
    return zlm.Mat4.createTranslationXYZ(-from[0], from[1], 0.0);
}

fn ortho(zoom: f32, width: f32, height: f32) zlm.Mat4 {
    return zlm.Mat4.createOrthogonal(-width * zoom, width * zoom, -height * zoom, height * zoom, -1.0, 1.0);
}

const shader = @import("shader.zig");

pub const Camera = struct {
    zoom: f32,
    position: [2]f32,
    view: zlm.Mat4,
    projection: zlm.Mat4,

    const Self = @This();

    pub fn create(width: u32, height: u32) Self {
        var self: Self = undefined;
        self.zoom = 0.001;
        self.position = .{ 0.0, 0.0 };
        self.projection = ortho(self.zoom, @floatFromInt(width), @floatFromInt(height));
        self.view = view(self.position);
        return self;
    }

    pub fn update_size(self: *Self, size: glfw.Window.Size) void {
        self.projection = ortho(self.zoom, @floatFromInt(size.width), @floatFromInt(size.height));
    }

    pub fn update_zoom(self: *Self, offset: f32, size: glfw.Window.Size) void {
        self.zoom += offset;
        self.zoom = @max(0.0001, self.zoom);
        self.projection = ortho(self.zoom, @floatFromInt(size.width), @floatFromInt(size.height));
    }

    pub fn move(self: *Self, x: f32, y: f32) void {
        const speed = self.zoom * 15.0;
        self.position[0] += x * speed;
        self.position[1] += y * speed;
        self.view = view(self.position);
    }

    pub fn matrix(self: *Self) zlm.Mat4 {
        return self.projection.mul(self.view);
    }

    pub fn update(self: *Self, move_flags: u8, shaders: []shader.program) void {
        if (move_flags & 0b0001 != 0) {
            self.move(0.0, -1.0);
        }
        if (move_flags & 0b0010 != 0) {
            self.move(-1.0, 0.0);
        }
        if (move_flags & 0b0100 != 0) {
            self.move(0.0, 1.0);
        }
        if (move_flags & 0b1000 != 0) {
            self.move(1.0, 0.0);
        }

        if (move_flags != 0) {
            for (shaders) |shdr| {
                shdr.use();
                _ = shdr.set_uniform_mat4x4("u_camera", &self.matrix());
            }
        }
    }
};
