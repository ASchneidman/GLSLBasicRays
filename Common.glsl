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




struct Ray {
    vec3 origin;
    vec3 direction;
};


void Ray_Transform(inout Ray ray, mat4 m) {
    vec4 homogeneous = m * vec4(ray.origin, 1.0);
    ray.origin = homogeneous.xyz / homogeneous.w;

    ray.direction = (m * vec4(ray.direction, 0.0)).xyz;
}

struct Sphere {
    vec3 center;
    float radius;
};

struct Camera {
    vec3 position;
    mat4 rotation;

    float fov;
    float aspect_ratio;

    float move_sens;
};

Camera Camera_Reset(vec3 iResolution) {
    // Matrices are in column major order
    mat4 rotation = mat4(
        vec4(1.0, 0.0, 0.0, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(0.0, 0.0, 1.0, 0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );

    return Camera(
        vec3(0.0),
        rotation,
        90.0,
        iResolution.x / iResolution.y,
        0.015
    );
}

void Camera_Model_View(Camera camera, out mat4 model, out mat4 view) {
    // Precomputes view
    model = mat4(
            vec4(1.0, 0.0, 0.0, 0.0),
            vec4(0.0, 1.0, 0.0, 0.0),
            vec4(1.0, 0.0, 1.0, 0.0),
            vec4(camera.position.xyz, 1.0)
        ) * camera.rotation;

    view = inverse(model);
}

Camera Camera_Get_Cached(sampler2D camera_channel, vec3 iResolution) {
    vec3 position = texelFetch(camera_channel, ivec2(0, 0), 0).xyz;
    mat4 rotation = mat4(
        texelFetch(camera_channel, ivec2(1, 0), 0),
        texelFetch(camera_channel, ivec2(2, 0), 0),
        texelFetch(camera_channel, ivec2(3, 0), 0),
        texelFetch(camera_channel, ivec2(4, 0), 0)
    );

    return Camera(
        position,
        rotation,
        90.0,
        iResolution.x / iResolution.y,
        0.015
    );
}