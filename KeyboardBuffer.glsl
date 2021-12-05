
#iKeyboard
#iChannel0 "file://BufferA.glsl"
#iChannel1 "file://KeyboardBuffer.glsl"
#include "Common.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord ) 
{
    int id = int(floor(fragCoord.x));
    if (id >= 5 || fragCoord.y > 0.5) {
        discard;
        //discard;
    }

    // id 0 computes position
    // id 1 + i computes ith column of rotation

    Camera camera = Camera_Reset(iResolution);
    if (iFrame > 0) {
        camera = Camera_Get_Cached(iChannel1, iResolution);
    }


    if (id == 0) {
        fragColor = vec4(camera.position, 0.0);
        return;
    }
    fragColor = camera.rotation[id - 1];
}