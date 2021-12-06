
#iKeyboard
#iChannel0 "file://BufferA.glsl"
#iChannel1 "file://KeyboardBuffer.glsl"
#include "Common.glsl"

void mainImage( out vec4 fragColor, in vec2 fragCoord ) 
{
    int id = int(floor(fragCoord.x));
    if (id >= 6 || fragCoord.y > 0.5) {
        discard;
    }

    // id 0 computes position
    // id 1 + i computes ith column of rotation
    Camera camera = Camera_Reset(iResolution);
    if (iFrame > 0) {
        vec4 prev_iMouse = texelFetch(iChannel1, ivec2(5, 0), 0);
        camera = Camera_Get_Cached(iChannel1, iResolution);

        mat4 model, view, rotation;
        Camera_Model_View(camera, model, view, rotation);

        vec3 total_move = vec3(0.0);
        #if VSCODE
        if (isKeyDown(Key_Shift)) {
            camera.move_sens *= 2.0;
        }
        if (isKeyDown(Key_W)) {
            // Camera looks along -z axis, so 
            // take vector going along -z axis and transform
            total_move += Vector_Transform(vec3(0.0, 0.0, -1.0), model);
        }
        if (isKeyDown(Key_S)) {
            total_move += Vector_Transform(vec3(0.0, 0.0, 1.0), model);
        }
        if (isKeyDown(Key_D)) {
            total_move += Vector_Transform(vec3(1.0, 0.0, 0.0), model);
        }
        if (isKeyDown(Key_A)) {
            total_move += Vector_Transform(vec3(-1.0, 0.0, 0.0), model);
        }

        // Do translation
        if (iMouse.z > 0.0) {
            // Mouse is pressed, check if it was pressed last frame
            if (prev_iMouse.z > 0.0) {
                vec2 offset = (iMouse.xy - prev_iMouse.xy) * vec2(1.0, -1.0) * camera.move_sens;
                //vec3 euler_change = vec3(0.0, offset.yx);
                vec3 euler_change = vec3(offset.yx, 0.0);
                
                camera.euler_angles += euler_change;
            }
        }

        if (length(total_move) > 0.0) {
            camera.position += normalize(total_move) * camera.move_sens;
        }

        if (isKeyDown(Key_R)) {
            camera = Camera_Reset(iResolution);
        }
        #else
        
        #endif
    }

    if (id == 0) {
        fragColor = vec4(camera.euler_angles, 0.0);
        return;
    }
    if (id == 4) {
        fragColor = vec4(camera.position, 0.0);
        return;
    }
    if (id == 5) {
        fragColor = iMouse;
        return;
    }
    //fragColor = camera.rotation[id];

}