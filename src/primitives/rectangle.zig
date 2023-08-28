const shader = @import("../shader.zig");
const gl = @import("gl");

pub const RectangleDrawCommand = struct {
    program: shader.program,
    vertices: []const Vertex,
    vao: u32,
    vbo: u32,

    const Self = @This();

    pub fn create() Self {
        var self: Self = undefined;
        self.program = shader.program.new();

        self.program
            .attach("./assets/shader/rectangle.vert", shader.ShaderType.vertex)
            .attach("./assets/shader/rectangle.geom", shader.ShaderType.geometry)
            .attach("./assets/shader/rectangle.frag", shader.ShaderType.fragment)
            .link();
        _ = self.program.register_uniform("u_camera");

        gl.createVertexArrays(1, &self.vao);
        gl.bindVertexArray(self.vao);

        gl.createBuffers(1, &self.vbo);
        self.vertices = @as([]const Vertex, &[_]Vertex{
            .{ .position = .{ -0.5, -0.5 }, .size = .{ 1.0, 1.0 } },
        });
        gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo);
        gl.bufferData(gl.ARRAY_BUFFER, @as(i64, @bitCast(self.vertices.len * @sizeOf(Vertex))), self.vertices.ptr, gl.STATIC_DRAW);

        Vertex.layout();

        return self;
    }

    pub fn draw(self: *Self) void {
        self.program.use();
        gl.bindVertexArray(self.vao);
        gl.drawArrays(gl.POINTS, 0, @truncate(@as(i64, @bitCast(self.vertices.len))));
    }

    pub fn delete(self: *Self) void {
        self.program.delete();
        gl.deleteBuffers(1, &self.vbo);
        gl.deleteVertexArrays(1, &self.vao);
    }

    const Vertex = struct {
        position: [2]f32,
        size: [2]f32,

        const VertexSelf = @This();

        pub fn layout() void {
            gl.enableVertexAttribArray(0);
            gl.vertexAttribPointer(0, 2, gl.FLOAT, 0, @sizeOf(VertexSelf), @ptrFromInt(@offsetOf(VertexSelf, "position")));
            gl.enableVertexAttribArray(1);
            gl.vertexAttribPointer(1, 2, gl.FLOAT, 0, @sizeOf(VertexSelf), @ptrFromInt(@offsetOf(VertexSelf, "size")));
        }
    };
};
