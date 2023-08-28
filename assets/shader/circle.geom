#version 450 core

#define PI 3.1415
#define MAX_VERTICES 40

layout(points) in;
layout(line_strip, max_vertices = MAX_VERTICES+1) out;

layout(location = 0) in float geometry_radius[];

uniform mat4 u_camera;

void main() {

    float angle = 0.0;
    const float delta = (2.0 * PI) / float(MAX_VERTICES);

    for(uint i = 0; i <= MAX_VERTICES; i++, angle += delta) {
        gl_Position = u_camera * (gl_in[0].gl_Position + geometry_radius[0] * vec4(cos(angle), sin(angle), 0.0, 0.0));
        EmitVertex();
    }

    EndPrimitive();
}
