#iChannel0 "file://BufferA.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 screen_coord = fragCoord / iResolution.xy;

    fragColor = vec4(texture(iChannel0, screen_coord));
}