#version 450 core

layout(location = 0) in vec2 v_position;

layout(location = 0) out vec4 color;

void main() {

    color = vec4(v_position, 0.8, 1.0);

}
