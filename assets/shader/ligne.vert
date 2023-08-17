#version 450 core

layout(location=0) in vec2 ligne ;

void main() {
    gl_Position = vec4( ligne , 0.0 , 1.0 );
}