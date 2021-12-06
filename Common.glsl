#define VSCODE 1

#define PI 3.14159
#define UP vec3(0.0, 1.0, 0.0)
#define Radians(x) ((x) * PI / 180.0)
#define Degrees(x) ((x) * 180.0 / PI)


// Utility Functions

vec3 hsv2rgb(vec3 c)
{
    // from https://stackoverflow.com/questions/15095909/from-rgb-to-hsv-in-opengl-glsl
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


mat4 euler_angles_to_rotation(vec3 ea) {
    return mat4(
        vec4(cos(ea.z) * cos(ea.x) - cos(ea.y) * sin(ea.x) * sin(ea.z), 
            -sin(ea.z) * cos(ea.x) - cos(ea.y) * sin(ea.x) * cos(ea.z),
            sin(ea.y) * sin(ea.x),
            0.0),
        vec4(cos(ea.z) * cos(ea.x) + cos(ea.y) * sin(ea.x) * sin(ea.z),
            -sin(ea.z) * cos(ea.x) + cos(ea.y) * cos(ea.x) * cos(ea.z),
            -sin(ea.y) * cos(ea.x),
            0.0),
        vec4(sin(ea.z) * sin(ea.y),
            cos(ea.z) * sin(ea.y),
            cos(ea.y),
            0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
}



struct Ray {
    vec3 origin;
    vec3 direction;
};

vec3 Vector_Transform(vec3 v, mat4 m) {
    return (m * vec4(v, 0.0)).xyz;
}

void Ray_Transform(inout Ray ray, mat4 m) {
    vec4 homogeneous = m * vec4(ray.origin, 1.0);
    ray.origin = homogeneous.xyz / homogeneous.w;

    ray.direction = Vector_Transform(ray.direction, m);
}

struct Sphere {
    vec3 center;
    float radius;
};

struct Camera {
    vec3 position;
    vec3 euler_angles;
    //mat4 rotation;

    float fov;
    float aspect_ratio;

    float move_sens;
};

Camera Camera_Reset(vec3 iResolution) {
    // Matrices are in column major order
    /*
    mat4 rotation = mat4(
        vec4(1.0, 0.0, 0.0, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(0.0, 0.0, 1.0, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );*/
    vec3 euler_angles = vec3(0.0, 0.0, 0.0);

    return Camera(
        vec3(0.0),
        euler_angles,
        90.0,
        iResolution.x / iResolution.y,
        0.015
    );
}

void Camera_Model_View(Camera camera, out mat4 model, out mat4 view, out mat4 rotation) {
    rotation = euler_angles_to_rotation(camera.euler_angles);
    // Precomputes view
    model = mat4(
            vec4(1.0, 0.0, 0.0, 0.0),
            vec4(0.0, 1.0, 0.0, 0.0),
            vec4(0.0, 0.0, 1.0, 0.0),
            vec4(camera.position.xyz, 1.0)
        ) * rotation;

    view = inverse(model);
}

Camera Camera_Get_Cached(sampler2D camera_channel, vec3 iResolution) {
    vec3 position = texelFetch(camera_channel, ivec2(4, 0), 0).xyz;
    vec3 euler_angles = texelFetch(camera_channel, ivec2(0, 0), 0).xyz;
    /*
    mat4 rotation = mat4(
        texelFetch(camera_channel, ivec2(0, 0), 0),
        texelFetch(camera_channel, ivec2(1, 0), 0),
        texelFetch(camera_channel, ivec2(2, 0), 0),
        texelFetch(camera_channel, ivec2(3, 0), 0)
    );
    */

    return Camera(
        position,
        euler_angles,
        90.0,
        iResolution.x / iResolution.y,
        0.015
    );
}