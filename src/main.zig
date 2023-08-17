const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("gl");

const shader = @import("shader.zig");

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
    _ = id;
    _ = length;
    _ = userParam;

    var source_name = switch (source) {
        gl.DEBUG_SOURCE_API => "API",
        gl.DEBUG_SOURCE_WINDOW_SYSTEM => "window system",
        gl.DEBUG_SOURCE_SHADER_COMPILER => "shader compiler",
        gl.DEBUG_SOURCE_THIRD_PARTY => "third party",
        gl.DEBUG_SOURCE_APPLICATION => "application",
        gl.DEBUG_SOURCE_OTHER => "other",
        else => "other",
    };

    var severity_name = switch (_type) {
        gl.DEBUG_TYPE_ERROR => "error",
        gl.DEBUG_TYPE_DEPRECATED_BEHAVIOR => "deprecated behaviour",
        gl.DEBUG_TYPE_UNDEFINED_BEHAVIOR => "undefined behaviour",
        gl.DEBUG_TYPE_PORTABILITY => "portability",
        gl.DEBUG_TYPE_PERFORMANCE => "performance",
        gl.DEBUG_TYPE_MARKER => "marker",
        gl.DEBUG_TYPE_PUSH_GROUP => "push group",
        gl.DEBUG_TYPE_POP_GROUP => "pop group",
        gl.DEBUG_TYPE_OTHER => "other",
        else => "other",
    };

    var type_name = switch (severity) {
        gl.DEBUG_SEVERITY_HIGH => "high",
        gl.DEBUG_SEVERITY_MEDIUM => "medium",
        gl.DEBUG_SEVERITY_LOW => "low",
        gl.DEBUG_SEVERITY_NOTIFICATION => "notification",
        else => "other",
    };

    std.log.err("GL ERROR[source: {s}, type: {s}, severity: {s}]: {s}\n", .{ source_name, type_name, severity_name, message });
}

const vertex_data = struct {
    start: [2]f32,
    control1: [2]f32,
    control2: [2]f32,
    end: [2]f32,

    const Self = @This();

    pub fn layout() void {
        gl.enableVertexAttribArray(0);
        gl.vertexAttribPointer(0, 2, gl.FLOAT, 0, @sizeOf(Self), null);
        gl.enableVertexAttribArray(1);
        gl.vertexAttribPointer(1, 2, gl.FLOAT, 0, @sizeOf(Self), @ptrFromInt(@offsetOf(Self, "control1")));
        gl.enableVertexAttribArray(2);
        gl.vertexAttribPointer(2, 2, gl.FLOAT, 0, @sizeOf(Self), @ptrFromInt(@offsetOf(Self, "control2")));
        gl.enableVertexAttribArray(3);
        gl.vertexAttribPointer(3, 2, gl.FLOAT, 0, @sizeOf(Self), @ptrFromInt(@offsetOf(Self, "end")));
    }
};

pub fn resize(window: glfw.Window, width: u32, height: u32) void {
    _ = window;
    gl.viewport(0, 0, @bitCast(width), @bitCast(height));
}

pub fn main() !void {
    glfw.setErrorCallback(errorCallback);
    if (!glfw.init(.{})) {
        std.log.err("failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    }
    defer glfw.terminate();
    // Create our window

    var size = glfw.Window.Size{ .width = 640, .height = 480 };

    const window = glfw.Window.create(size.width, size.height, "mach-glfw + zig-opengl", null, null, .{
        .opengl_profile = .opengl_core_profile,
        .context_version_major = 4,
        .context_version_minor = 5,
        .samples = 16,
    }) orelse {
        std.log.err("failed to create GLFW window: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    };
    defer window.destroy();
    // window.setFramebufferSizeCallback(resize);

    glfw.makeContextCurrent(window);
    glfw.swapInterval(1);

    const proc: glfw.GLProc = undefined;
    gl.load(proc, glGetProcAddress) catch |err| {
        std.debug.print("Error loading opengl functions: {}\n", .{err});
    };

    resize( window , size.width, size.height);

    gl.enable(gl.DEBUG_OUTPUT);
    gl.enable(gl.PROGRAM_POINT_SIZE);
    gl.enable(gl.MULTISAMPLE);

    gl.pointSize(6.0);
    gl.debugMessageCallback(errorGlCallback, null);

    var bezier_program = shader.program.new();
    bezier_program
        .attach("./assets/shader/bezier.vert", shader.ShaderType.vertex)
        .attach("./assets/shader/bezier.geom", shader.ShaderType.geometry)
        .attach("./assets/shader/bezier.frag", shader.ShaderType.fragment)
        .link();
    defer bezier_program.delete();

    var VAO: gl.GLuint = 0;
    var VBO: gl.GLuint = 0;

    gl.genVertexArrays(1, &VAO);
    gl.genBuffers(1, &VBO);

    defer gl.deleteVertexArrays(1, &VAO);
    defer gl.deleteBuffers(1, &VBO);

    gl.bindVertexArray(VAO);

    var buf = [_]f32{ -1, -1, -0.5, 0.5, 0.5, 0.5, 1, -1 };
    var vertices = @as([]f32, &buf);
    gl.bindBuffer(gl.ARRAY_BUFFER, VBO);
    gl.bufferData(gl.ARRAY_BUFFER, @bitCast(vertices.len * @sizeOf(f32)), vertices.ptr, gl.STATIC_DRAW);

    vertex_data.layout();

    //

    var monprogrammeamoiquejai = shader.program.new();
    monprogrammeamoiquejai
        .attach("./assets/shader/ligne.vert", shader.ShaderType.vertex)
        .attach("./assets/shader/ligne.frag", shader.ShaderType.fragment)
        .link();
    defer monprogrammeamoiquejai.delete();


    var BackgroundVertexArray  : gl.GLuint = 0; // VAO
    var BackgroundVertexBuffer : gl.GLuint = 0; // VBO

    gl.genVertexArrays(1, &BackgroundVertexArray);
    gl.genBuffers(1, &BackgroundVertexBuffer);

    defer gl.deleteVertexArrays(1, &BackgroundVertexArray); // suppression à la fin
    defer gl.deleteBuffers(1, &BackgroundVertexBuffer);     // suppression à la fin

    gl.bindVertexArray(BackgroundVertexArray);

    var ligne = [_]f32{ -1.0,0.0,1.0,0.0,
                        -1.0,0.5,1.0,0.5,
                        -1.0,-0.5,1.0,-0.5,
                        0.0,1.0,0.0,-1.0,
                        0.5,1.0,0.5,-1.0,
                        -0.5,1.0,-0.5,-1.0,
                        
                        };
    gl.bindBuffer(gl.ARRAY_BUFFER,BackgroundVertexBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, ligne.len * @sizeOf(f32), &ligne, gl.STATIC_DRAW );

    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(0, 2, gl.FLOAT, 0, 2 * @sizeOf(f32), null);



    //


    gl.clearColor(30.0 / 255.0, 30.0 / 255.0, 30.0 / 255.0, 1.0);
    // Wait for the user to close the window.
    
    while (!window.shouldClose()) {
        gl.clear(gl.COLOR_BUFFER_BIT);
        
        size = window.getSize();   
        resize(window,size.width,size.height);

        monprogrammeamoiquejai.use();
        gl.bindVertexArray(BackgroundVertexArray);
        gl.drawArrays(gl.LINES, 0, 12);

        bezier_program.use();
        gl.bindVertexArray(VAO);
        gl.drawArrays(gl.POINTS, 0, 1);

        window.swapBuffers();
        glfw.pollEvents();
    }


}
