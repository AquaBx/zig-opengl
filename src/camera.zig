const std = @import("std");
const zlm = @import("zlm");

fn view(from: [2]f32) zlm.Mat4 {
    return zlm.Mat4.createTranslationXYZ(-from[0], from[1], 0.0);
}

fn ortho(ratio: f32, zoom: f32) zlm.Mat4 {
    return zlm.Mat4.createOrthogonal(-ratio * zoom, ratio * zoom, -zoom, zoom, -1.0, 1.0);
}

pub const Camera = struct {
    zoom: f32,
    ratio: f32,
    position: [2]f32,
    view: zlm.Mat4,
    projection: zlm.Mat4,

    const Self = @This();

    pub fn create(ratio: f32) Self {
        var self: Self = undefined;
        self.zoom = 0.25;
        self.ratio = ratio;
        self.position = .{ 0.0, 0.0 };
        self.projection = ortho(self.ratio, self.zoom);
        self.view = view(self.position);
        return self;
    }

    pub fn update_ratio(self: *Self, ratio: f32) void {
        self.ratio = ratio;
        self.projection = ortho(self.ratio, self.zoom);
    }

    pub fn update_zoom(self: *Self, offset: f32) void {
        self.zoom -= offset;
        self.zoom = @max(0.5, self.zoom);
        self.projection = ortho(self.ratio, self.zoom);
    }

    pub fn move(self: *Self, x: f32, y: f32) void {
        const speed = 1.0 / (1.5 * self.zoom);
        self.position[0] += x * speed;
        self.position[1] += y * speed;
        self.view = view(self.position);
    }

    pub fn matrix(self: *Self) zlm.Mat4 {
        return self.projection.mul(self.view);
    }
};
