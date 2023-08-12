const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("gl");

const log = std.log.scoped(.Engine);

fn glGetProcAddress(p: glfw.GLProc, proc: [:0]const u8) ?gl.FunctionPointer {
    _ = p;
    return glfw.getProcAddress(proc);
}

/// Default GLFW error handling callback
fn errorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("glfw: {}: {s}\n", .{ error_code, description });
}

fn errorGlCallback(source: gl.GLenum, _type: gl.GLenum, id: gl.GLuint, severity: gl.GLenum, length: gl.GLsizei, message: [*:0]const u8, userParam: ?*anyopaque) callconv(.C) void {
    _ = source;
    _ = _type;
    _ = id;
    _ = severity;
    _ = length;
    _ = userParam;

    std.log.err("gl: {s}\n", .{message});
}

pub fn main() !void {
    glfw.setErrorCallback(errorCallback);
    if (!glfw.init(.{})) {
        std.log.err("failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    }
    defer glfw.terminate();

    // Create our window
    const window = glfw.Window.create(640, 480, "mach-glfw + zig-opengl", null, null, .{
        .opengl_profile = .opengl_core_profile,
        .context_version_major = 4,
        .context_version_minor = 0,
    }) orelse {
        std.log.err("failed to create GLFW window: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    };
    defer window.destroy();

    glfw.makeContextCurrent(window);

    const proc: glfw.GLProc = undefined;
    try gl.load(proc, glGetProcAddress);

    // test du polygon

    var a = "#version 330 core\nlayout (location = 0) in vec3 aPos;\nvoid main() {\n    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n}";
    var b = "#version 330 core\nout vec4 FragColor;\nvoid main()\n{FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n}";

    gl.viewport(0, 0, 640, 480);

    gl.enable(gl.DEBUG_OUTPUT);
    gl.debugMessageCallback(errorGlCallback, null);

    const vertices = [_]f32{ -0.5, -0.5 * 0.58, 0, 0.5, -0.5 * 0.58, 0, 0.0, 1.0 * 0.58, 0 };

    var vertexShaderSource = [_][*:0]const u8{a};
    const vertexShader: gl.GLuint = gl.createShader(gl.VERTEX_SHADER);
    gl.shaderSource(vertexShader, 1, &vertexShaderSource, null);
    gl.compileShader(vertexShader);

    var fragmentShaderSource = [_][*:0]const u8{b};
    const fragmentShader: gl.GLuint = gl.createShader(gl.FRAGMENT_SHADER);
    gl.shaderSource(fragmentShader, 1, &fragmentShaderSource, null);
    gl.compileShader(fragmentShader);

    const shaderProgram: gl.GLuint = gl.createProgram();
    gl.attachShader(shaderProgram, vertexShader);
    gl.attachShader(shaderProgram, fragmentShader);

    gl.linkProgram(shaderProgram);
    gl.deleteShader(vertexShader);
    gl.deleteShader(fragmentShader);

    var VAO: gl.GLuint = 0;
    var VBO: gl.GLuint = 0;

    gl.genVertexArrays(1, &VAO);
    gl.genBuffers(1, &VBO);

    gl.bindVertexArray(VAO);

    gl.bindBuffer(gl.ARRAY_BUFFER, VBO);
    gl.bufferData(gl.ARRAY_BUFFER, vertices.len * @sizeOf(f32), &vertices, gl.STATIC_DRAW);

    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), null);
    gl.enableVertexAttribArray(0);

    gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    gl.bindVertexArray(0);

    // Wait for the user to close the window.
    while (!window.shouldClose()) {
        gl.clearColor(0, 0, 0, 1);
        gl.clear(gl.COLOR_BUFFER_BIT);

        gl.useProgram(shaderProgram);
        gl.bindVertexArray(VAO);
        gl.drawArrays(gl.TRIANGLES, 0, 3);

        window.swapBuffers();
        glfw.pollEvents();
    }

    gl.deleteVertexArrays(1, &VAO);
    gl.deleteBuffers(1, &VBO);
    gl.deleteProgram(shaderProgram);
}
