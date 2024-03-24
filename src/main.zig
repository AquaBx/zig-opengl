const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("gl");

const shader = @import("shader.zig");
const square = @import("components/square.zig").Square;

const vertexShaderSource =
    \\ #version 410 core
    \\ layout (location = 0) in vec3 aPos;
    \\ void main()
    \\ {
    \\   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    \\ }
;

const fragmentShaderSource =
    \\ #version 410 core
    \\ out vec4 FragColor;
    \\ void main() {
    \\  FragColor = vec4(1.0, 1.0, 0.2, 1.0);   
    \\ }
;

const WindowSize = struct {
    pub const width: u32 = 800;
    pub const height: u32 = 600;
};

pub fn main() !void {

    // glfw: initialize and configure
    // ------------------------------
    if (!glfw.init(.{})) {
        std.log.err("GLFW initialization failed", .{});
        return;
    }
    defer glfw.terminate();

    // glfw window creation
    // --------------------
    const window = glfw.Window.create(WindowSize.width, WindowSize.height, "mach-glfw + zig-opengl", null, null, .{
        .opengl_profile = .opengl_core_profile,
        .context_version_major = 4,
        .context_version_minor = 5,
    }) orelse {
        std.log.err("GLFW Window creation failed", .{});
        return;
    };
    defer window.destroy();

    glfw.makeContextCurrent(window);
    window.setFramebufferSizeCallback(resize);
    glfw.swapInterval(1);

    const proc: glfw.GLProc = undefined;
    try gl.load(proc, glGetProcAddress);

    var nprogram = shader.program.new();
    nprogram.attach("./assets/shader/house.geom", shader.ShaderType.geometry)
        .attach("./assets/shader/triangle.frag", shader.ShaderType.fragment)
        .attach("./assets/shader/triangle.vert", shader.ShaderType.vertex)
        .link();
    defer nprogram.delete();

    var nsquare = square.init(0, 0);
    defer nsquare.destroy();

    while (!window.shouldClose()) {
        processInput(window);

        gl.clearColor(0.2, 0.3, 0.3, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT);

        nprogram.use();
        nsquare.draw();

        window.swapBuffers();
        glfw.pollEvents();
    }
}

fn glGetProcAddress(p: glfw.GLProc, proc: [:0]const u8) ?gl.FunctionPointer {
    _ = p;
    return glfw.getProcAddress(proc);
}

fn processInput(window: glfw.Window) void {
    if (glfw.Window.getKey(window, glfw.Key.escape) == glfw.Action.press) {
        _ = glfw.Window.setShouldClose(window, true);
    }
}

pub fn resize(window: glfw.Window, width: u32, height: u32) void {
    _ = window;
    gl.viewport(0, 0, @intCast(width), @intCast(height));
}
