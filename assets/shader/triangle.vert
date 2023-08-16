#version 450 core

layout(location = 0) in vec3 a_position;

layout(location = 0) out vec2 v_position;

void main() {
    gl_Position = vec4(a_position.xyz, 1.0);
    v_position = a_position.xy;
}
