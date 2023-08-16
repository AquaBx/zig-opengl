#version 450 core

layout(location = 0) in vec2 vertex_start;
layout(location = 1) in vec2 vertex_control1;
layout(location = 2) in vec2 vertex_control2;
layout(location = 3) in vec2 vertex_end;

layout(location = 0) out vec2 geometry_start;
layout(location = 1) out vec2 geometry_control1;
layout(location = 2) out vec2 geometry_control2;
layout(location = 3) out vec2 geometry_end;

void main() {
    geometry_start = vertex_start;
    geometry_control1 = vertex_control1;
    geometry_control2 = vertex_control2;
    geometry_end = vertex_end;
}
