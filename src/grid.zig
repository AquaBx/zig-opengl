const gl = @import("gl");
const shader = @import("shader.zig");

pub const GridDrawCommand = struct {
    program: shader.program,
    vertices: []const f32,
    vao: u32,
    vbo: u32,

    const Self = @This();

    pub fn create() Self {
        var self: Self = undefined;
        self.program = shader.program.new();
        self.program
            .attach("./assets/shader/line.vert", shader.ShaderType.vertex)
            .attach("./assets/shader/line.frag", shader.ShaderType.fragment)
            .link();

        gl.createVertexArrays(1, &self.vao);
        gl.bindVertexArray(self.vao);

        self.vertices = @as([]const f32, &[_]f32{
            -1.0, 0.0,  1.0,  0.0,
            -1.0, 0.5,  1.0,  0.5,
            -1.0, -0.5, 1.0,  -0.5,
            0.0,  1.0,  0.0,  -1.0,
            0.5,  1.0,  0.5,  -1.0,
            -0.5, 1.0,  -0.5, -1.0,
        });
        gl.createBuffers(1, &self.vbo);
        gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo);
        gl.bufferData(gl.ARRAY_BUFFER, @bitCast(self.vertices.len * @sizeOf(f32)), self.vertices.ptr, gl.STATIC_DRAW);

        Vertex.layout();

        return self;
    }

    pub fn draw(self: *Self) void {
        self.program.use();
        gl.bindVertexArray(self.vao);
        gl.drawArrays(gl.LINES, 0, Vertex.Count);
    }

    pub fn delete(self: *Self) void {
        self.program.delete();
        gl.deleteVertexArrays(1, &self.vao);
        gl.deleteBuffers(1, &self.vbo);
    }

    const Vertex = struct {
        anchor: [2]f32,

        const VertexSelf = @This();
        const Count = 12;

        pub fn layout() void {
            gl.enableVertexAttribArray(0);
            gl.vertexAttribPointer(0, 2, gl.FLOAT, 0, @sizeOf(VertexSelf), @ptrFromInt(@offsetOf(VertexSelf, "anchor")));
        }
    };
};
