// const utils = @import("utils.zig");
const std = @import("std");
const math = @import("zlm");
const shader = @import("../shader.zig");
const gl = @import("gl");

pub const Square = struct {
    vao: gl.GLuint,
    vbo: gl.GLuint,
    ibo: gl.GLuint,
    scale: f32,
    x: usize,
    y: usize,

    const Self = @This();

    pub fn init(x: usize, y: usize) Self {
        const vertices = [2]f32{ -0.5, 0.5 };
        var VBO: c_uint = undefined;
        var VAO: c_uint = undefined;

        gl.genVertexArrays(1, &VAO);

        gl.genBuffers(1, &VBO);

        gl.bindVertexArray(VAO);

        gl.bindBuffer(gl.ARRAY_BUFFER, VBO);

        gl.bufferData(gl.ARRAY_BUFFER, @sizeOf(f32) * vertices.len, &vertices, gl.STATIC_DRAW);

        gl.vertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, 2 * @sizeOf(f32), null);
        gl.enableVertexAttribArray(0);

        return .{
            .vao = VAO,
            .vbo = VBO,
            .ibo = 0,
            .x = x,
            .y = y,
            .scale = 0.5,
        };
    }

    pub fn destroy(self: Self) void {
        gl.deleteVertexArrays(1, &self.vao);
        gl.deleteBuffers(1, &self.vbo);
    }

    pub fn render(self: Self, program: shader.program) void {
        program.use();
        gl.bindVertexArray(self.vao);
        gl.drawArrays(gl.TRIANGLES, 0, 3);
    }

    pub fn draw(self: Self) void {
        gl.bindVertexArray(self.vao);
        gl.drawArrays(gl.POINTS, 0, 1);
    }
};
