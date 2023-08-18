const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("gl");
const zlm = @import("zlm");

const ApplicationContext = @import("application.zig").ApplicationContext;
const Camera = @import("camera.zig").Camera;

const utils = @import("utils.zig");
const shader = @import("shader.zig");
const callback = @import("callback.zig");

pub fn main() !void {
    if (!glfw.init(.{})) {
        std.debug.print("failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    }
    defer glfw.terminate();

    // Create our window
    const window = glfw.Window.create(640, 480, "mach-glfw + zig-opengl", null, null, .{
        .opengl_profile = .opengl_core_profile,
        .context_version_major = 4,
        .context_version_minor = 5,
        .samples = 16,
    }) orelse {
        std.debug.print("failed to create GLFW window: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    };
    defer window.destroy();

    glfw.makeContextCurrent(window);

    const proc: glfw.GLProc = undefined;
    gl.load(proc, callback.get_proc_address) catch |err| {
        std.debug.print("Error loading opengl functions: {}\n", .{err});
    };

    var ctx = ApplicationContext.create();
    defer ctx.delete();

    // GLFW Config
    glfw.swapInterval(1);
    glfw.setErrorCallback(callback.GLFWError);

    window.setUserPointer(&ctx);
    window.setFramebufferSizeCallback(callback.resize);
    window.setScrollCallback(callback.scroll);

    // OpenGL Config
    callback.resize(window, 640, 480);

    gl.enable(gl.DEBUG_OUTPUT);
    gl.enable(gl.PROGRAM_POINT_SIZE);
    gl.enable(gl.MULTISAMPLE);
    gl.enable(gl.DEPTH_TEST);

    gl.pointSize(6.0);
    gl.debugMessageCallback(callback.GLError, null);

    const background_color = utils.from_rgba(30, 30, 30, 255);
    gl.clearColor(background_color[0], background_color[1], background_color[2], background_color[3]);

    // Wait for the user to close the window.
    while (!window.shouldClose()) {
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

        ctx.grid.draw();
        ctx.bezier.draw();

        window.swapBuffers();
        glfw.pollEvents();

        update_camera(window, ctx);
    }
}

fn update_camera(window: glfw.Window, ctx: ApplicationContext) void {
    const moved: u8 = @as(u8, @intFromBool(window.getKey(glfw.Key.w) == glfw.Action.press)) | @as(u8, @intFromBool(window.getKey(glfw.Key.a) == glfw.Action.press)) << 1 | @as(u8, @intFromBool(window.getKey(glfw.Key.s) == glfw.Action.press)) << 2 | @as(u8, @intFromBool(window.getKey(glfw.Key.d) == glfw.Action.press)) << 3;

    if (moved & 0b0001 != 0) {
        ctx.camera.move(0.0, -0.1);
    }
    if (moved & 0b0010 != 0) {
        ctx.camera.move(-0.1, 0.0);
    }
    if (moved & 0b0100 != 0) {
        ctx.camera.move(0.0, 0.1);
    }
    if (moved & 0b1000 != 0) {
        ctx.camera.move(0.1, 0.0);
    }

    if (moved != 0) {
        ctx.bezier.program.use();
        _ = ctx.bezier.program.set_uniform_mat4x4("u_camera", &ctx.camera.matrix());
    }
}
