#version 450 core

layout(location = 0) in vec2 vertex_center;
layout(location = 1) in float vertex_radius;

layout(location = 0) out float geometry_radius;

void main() {
    geometry_radius = vertex_radius;
    gl_Position = vec4(vertex_center, 0.0, 1.0);
}
