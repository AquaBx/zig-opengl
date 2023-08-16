#version 450 core

layout(location = 0) in vec4 fragment_color;

layout(location = 0) out vec4 color;

void main() {
    // color = vec4(91.0 / 255.0, 154.0 / 255.0, 139.0 / 255.0, 1.0);
    color = fragment_color;
}
