const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("gl");
const zlm = @import("zlm");

const ApplicationContext = @import("application.zig").ApplicationContext;
const utils = @import("utils.zig");

pub fn main() !void {
    var ctx: ApplicationContext = undefined;
    ctx.create();
    defer ctx.delete();

    const background_color = utils.from_rgba(30, 30, 30, 255);
    gl.clearColor(background_color[0], background_color[1], background_color[2], background_color[3]);

    // Wait for the user to close the window.
    while (!ctx.window.shouldClose()) {
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

        ctx.bezier.draw();
        ctx.rectangle.draw();
        ctx.circle.draw();

        ctx.window.swapBuffers();
        glfw.pollEvents();

        const moved: u8 = @as(u8, @intFromBool(ctx.window.getKey(glfw.Key.w) == glfw.Action.press)) | @as(u8, @intFromBool(ctx.window.getKey(glfw.Key.a) == glfw.Action.press)) << 1 | @as(u8, @intFromBool(ctx.window.getKey(glfw.Key.s) == glfw.Action.press)) << 2 | @as(u8, @intFromBool(ctx.window.getKey(glfw.Key.d) == glfw.Action.press)) << 3;
        ctx.camera.update(moved, .{ ctx.bezier.program, ctx.rectangle.program, ctx.circle.program });
    }
}
