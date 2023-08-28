const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("gl");

const callback = @import("callback.zig");

const Camera = @import("camera.zig").Camera;
const BezierDrawCommand = @import("./primitives/bezier.zig").BezierDrawCommand;
const RectangleDrawCommand = @import("./primitives/rectangle.zig").RectangleDrawCommand;
const CircleDrawCommand = @import("./primitives/circle.zig").CircleDrawCommand;

pub const ApplicationContext = struct {
    window: glfw.Window,
    camera: Camera,
    bezier: BezierDrawCommand,
    rectangle: RectangleDrawCommand,
    circle: CircleDrawCommand,

    const Self = @This();

    pub const Width = 640;
    pub const Height = 480;

    pub fn create(self: *Self) void {
        if (!glfw.init(.{})) {
            std.debug.print("failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
            std.process.exit(1);
        }

        self.window = glfw.Window.create(ApplicationContext.Width, ApplicationContext.Height, "mach-glfw + zig-opengl", null, null, .{
            .opengl_profile = .opengl_core_profile,
            .context_version_major = 4,
            .context_version_minor = 5,
            .samples = 16,
        }) orelse {
            std.debug.print("failed to create GLFW window: {?s}", .{glfw.getErrorString()});
            std.process.exit(1);
        };
        glfw.makeContextCurrent(self.window);

        const proc: glfw.GLProc = undefined;
        gl.load(proc, callback.get_proc_address) catch |err| {
            std.debug.print("Error loading opengl functions: {}\n", .{err});
        };

        // GLFW Config
        glfw.swapInterval(1);
        glfw.setErrorCallback(callback.GLFWError);

        self.window.setFramebufferSizeCallback(callback.resize);
        self.window.setScrollCallback(callback.scroll);
        self.window.setUserPointer(self);
        callback.resize(self.window, ApplicationContext.Width, ApplicationContext.Height);

        // OpenGL Config
        gl.enable(gl.DEBUG_OUTPUT);
        gl.enable(gl.PROGRAM_POINT_SIZE);
        gl.enable(gl.MULTISAMPLE);
        gl.enable(gl.DEPTH_TEST);

        gl.pointSize(6.0);
        gl.debugMessageCallback(callback.GLError, null);

        self.camera = Camera.create(ApplicationContext.Width, ApplicationContext.Height);
        self.bezier = BezierDrawCommand.create();
        self.rectangle = RectangleDrawCommand.create();
        self.circle = CircleDrawCommand.create();
    }

    pub fn delete(self: *Self) void {
        self.bezier.delete();
        self.rectangle.delete();
        self.circle.delete();

        self.window.destroy();
        glfw.terminate();
    }
};
