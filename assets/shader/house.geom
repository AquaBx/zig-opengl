#version 450 core
layout (points) in;
layout (line_strip, max_vertices = 1000) out;

void build_radius_top(vec4 position, float r , float xd, float x0, float y0 ){
    // left to right
    for ( float x = xd ; x <= xd + r; x+=r/50 ) {
        float y = sqrt(r*r - (x-x0)*(x-x0)) + y0;
        gl_Position = position + vec4(x,  y, 0.0, 0.0);
        EmitVertex();
    }
}

void build_radius_bottom(vec4 position, float r , float xd, float x0, float y0 ){
    //right to left
    for ( float x = xd ; x >= xd - r; x-=r/50 ) {
        float y = y0 - sqrt(r*r - (x-x0)*(x-x0));
        gl_Position = position + vec4(x,  y, 0.0, 0.0);
        EmitVertex();
    }
}

void build_square(vec4 position)
{    
    float r = 0.1;

    // top left

    build_radius_top(position,r,-0.2,-0.2+r,0.2-r);

    // top right

    build_radius_top(position,r,0.2-r,0.2-r,0.2-r);

    // bottom right
    build_radius_bottom(position,r,0.2,0.2-r,-0.2+r);

    // bottom left
    build_radius_bottom(position,r,-0.2+r,-0.2+r,-0.2+r);

    gl_Position = position + vec4(-0.2,  0.2-r, 0.0, 0.0);
    EmitVertex();

    EndPrimitive();
}

void main() {    
    build_square(gl_in[0].gl_Position);
}  