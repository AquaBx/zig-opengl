const gl = @import("gl");

const shader = @import("shader.zig");

pub const BezierDrawCommand = struct {
    program: shader.program,
    vertices: []const f32,
    vao: u32,
    vbo: u32,

    const Self = @This();

    pub fn create() Self {
        var self: Self = undefined;
        self.program = shader.program.new();
        // Bezier Setup
        self.program
            .attach("./assets/shader/bezier.vert", shader.ShaderType.vertex)
            .attach("./assets/shader/bezier.geom", shader.ShaderType.geometry)
            .attach("./assets/shader/bezier.frag", shader.ShaderType.fragment)
            .link();
        _ = self.program.register_uniform("u_camera");

        gl.genVertexArrays(1, &self.vao);
        gl.bindVertexArray(self.vao);

        gl.genBuffers(1, &self.vbo);

        self.vertices = @as([]const f32, &[_]f32{ -1, -1, -0.5, 0.5, 0.5, 0.5, 1, -1 });
        gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo);
        gl.bufferData(gl.ARRAY_BUFFER, @bitCast(self.vertices.len * @sizeOf(f32)), self.vertices.ptr, gl.STATIC_DRAW);

        Vertex.layout();

        return self;
    }

    pub fn draw(self: *Self) void {
        self.program.use();
        gl.bindVertexArray(self.vao);
        gl.drawArrays(gl.POINTS, 0, Vertex.Count);
    }

    pub fn delete(self: *Self) void {
        self.program.delete();
        gl.deleteVertexArrays(1, &self.vao);
        gl.deleteBuffers(1, &self.vbo);
    }

    const Vertex = struct {
        start: [2]f32,
        control1: [2]f32,
        control2: [2]f32,
        end: [2]f32,

        const VertexSelf = @This();
        const Count = 1;

        pub fn layout() void {
            gl.enableVertexAttribArray(0);
            gl.vertexAttribPointer(0, 2, gl.FLOAT, 0, @sizeOf(VertexSelf), @ptrFromInt(@offsetOf(VertexSelf, "start")));
            gl.enableVertexAttribArray(1);
            gl.vertexAttribPointer(1, 2, gl.FLOAT, 0, @sizeOf(VertexSelf), @ptrFromInt(@offsetOf(VertexSelf, "control1")));
            gl.enableVertexAttribArray(2);
            gl.vertexAttribPointer(2, 2, gl.FLOAT, 0, @sizeOf(VertexSelf), @ptrFromInt(@offsetOf(VertexSelf, "control2")));
            gl.enableVertexAttribArray(3);
            gl.vertexAttribPointer(3, 2, gl.FLOAT, 0, @sizeOf(VertexSelf), @ptrFromInt(@offsetOf(VertexSelf, "end")));
        }
    };
};
