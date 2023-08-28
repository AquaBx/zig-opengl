#version 450 core

layout(location = 0) in vec2 vertex_position;
layout(location = 1) in vec2 vertex_size;

layout(location = 0) out vec2 geometry_size;

void main() {
    geometry_size = vertex_size;
    gl_Position = vec4(vertex_position, 0.0, 1.0);
}
