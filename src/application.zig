const Camera = @import("camera.zig").Camera;
const BezierDrawCommand = @import("bezier.zig").BezierDrawCommand;
const GridDrawCommand = @import("grid.zig").GridDrawCommand;

pub const ApplicationContext = struct {
    camera: Camera,
    bezier: BezierDrawCommand,
    grid: GridDrawCommand,

    const Self = @This();

    pub fn create() Self {
        return .{
            .camera = Camera.create(640.0 / 480.0),
            .bezier = BezierDrawCommand.create(),
            .grid = GridDrawCommand.create(),
        };
    }

    pub fn delete(self: *Self) void {
        self.bezier.delete();
        self.grid.delete();
    }
};
