#version 450 core

#define MAX_VERTICES 150

layout(points) in;
layout(line_strip, max_vertices = MAX_VERTICES) out;

layout(location = 0) in vec2 geometry_start[];
layout(location = 1) in vec2 geometry_control1[];
layout(location = 2) in vec2 geometry_control2[];
layout(location = 3) in vec2 geometry_end[];

uniform mat4 u_camera;

void main() {
    const int segments = MAX_VERTICES - 1;
    const float delta = 1.0 / float(segments);
    float t = 0.0;

    for(int i = 0; i <= segments; i++) {
        gl_Position = u_camera * (vec4(geometry_end[0] * t*t*t , 0.0, 0.25) 
                    + vec4(geometry_control2[0] * 3*t*t*(1-t)      , 0.0, 0.25) 
                    + vec4(geometry_control1[0] * 3*t*  (1-t)*(1-t), 0.0, 0.25) 
                    + vec4(geometry_start[0]    * (1-t)*(1-t)*(1-t), 0.0, 0.25)
        );
        t += delta;
        EmitVertex();
    }

    EndPrimitive();
}
