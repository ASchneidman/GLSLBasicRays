#define PI 3.14159
#define UP vec3(0.0, 1.0, 0.0)
#define Radians(x) ((x) * PI / 180.0)
#define Degrees(x) ((x) * 180.0 / PI)

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