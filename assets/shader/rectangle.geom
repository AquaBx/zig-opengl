#version 450 core

layout(points) in;
layout(line_strip, max_vertices = 5) out;

layout(location = 0) in vec2 geometry_size[];

uniform mat4 u_camera;

void main() {
    // up left
    gl_Position = u_camera * gl_in[0].gl_Position;
    EmitVertex();

    // down left
    gl_Position = u_camera * (gl_in[0].gl_Position + vec4(0.0, geometry_size[0].y, 0.0, 0.0));
    EmitVertex();

    // down right
    gl_Position = u_camera * (gl_in[0].gl_Position + vec4(geometry_size[0], 0.0, 0.0));
    EmitVertex();

    // up right
    gl_Position = u_camera * (gl_in[0].gl_Position + vec4(geometry_size[0].x, 0.0, 0.0, 0.0));
    EmitVertex();

    // up left
    gl_Position = u_camera * gl_in[0].gl_Position;
    EmitVertex();
    
    EndPrimitive();
}
