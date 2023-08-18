const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("gl");

pub fn get_proc_address(_: glfw.GLProc, proc: [:0]const u8) ?gl.FunctionPointer {
    return glfw.getProcAddress(proc);
}

/// Default GLFW error handling callback
pub fn GLFWError(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    std.log.err("glfw: {}: {s}\n", .{ error_code, description });
}

pub fn GLError(source: gl.GLenum, _type: gl.GLenum, _: gl.GLuint, severity: gl.GLenum, _: gl.GLsizei, message: [*:0]const u8, _: ?*anyopaque) callconv(.C) void {
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

const ApplicationContext = @import("application.zig").ApplicationContext;

pub fn scroll(window: glfw.Window, _: f64, y_offset: f64) void {
    if (y_offset == 0.0) return;

    if (window.getUserPointer(ApplicationContext)) |ctx| {
        ctx.camera.update_zoom(@floatCast(y_offset));
        ctx.bezier.program.use();
        _ = ctx.bezier.program.set_uniform_mat4x4("u_camera", &ctx.camera.matrix());
    }
}

pub fn resize(window: glfw.Window, width: u32, height: u32) void {
    if (window.getUserPointer(ApplicationContext)) |ctx| {
        ctx.camera.update_ratio(@as(f32, @floatFromInt(height)) / @as(f32, @floatFromInt(width)));
        ctx.bezier.program.use();
        _ = ctx.bezier.program.set_uniform_mat4x4("u_camera", &ctx.camera.matrix());
    }
    gl.viewport(0, 0, @bitCast(width), @bitCast(height));
}
