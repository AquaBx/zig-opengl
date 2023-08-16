#version 450 core

layout(points) in;
layout(line_strip, max_vertices = 150) out;
// layout(points, max_vertices = 3) out;

layout(location = 0) in vec2 geometry_start[];
layout(location = 1) in vec2 geometry_control1[];
layout(location = 2) in vec2 geometry_control2[];
layout(location = 3) in vec2 geometry_end[];

layout(location = 0) out vec4 fragment_color;

void main() {
    const int segments = 149;
    const float delta = 1.0 / float(segments);
    float t = 0.0;

    for(int i = 0; i <= segments; i++) {
        gl_Position = vec4(geometry_end[0]      * t * t * t                 , 0.0, 0.25) 
                    + vec4(geometry_control2[0] * 3 * t * t * (1 - t)       , 0.0, 0.25) 
                    + vec4(geometry_control1[0] * 3 * t  * (1 - t) * (1 - t), 0.0, 0.25) 
                    + vec4(geometry_start[0]   * (1 - t) * (1 - t) * (1 - t), 0.0, 0.25)
        ;
        t += delta;
        EmitVertex();
    }

    // gl_Position = vec4(geometry_start[0], 0.0, 1.0);
    // fragment_color = vec4(1.0, 0.0, 0.0, 1.0);
    // EmitVertex();

    // gl_Position = vec4(geometry_control[0], 0.0, 1.0);
    // fragment_color = vec4(0.0, 1.0, 0.0, 1.0);
    // EmitVertex();

    // gl_Position = vec4(geometry_end[0], 0.0, 1.0);
    // fragment_color = vec4(0.0, 0.0, 1.0, 1.0);
    // EmitVertex();

    EndPrimitive();
}
