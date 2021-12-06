#iChannel0 "file://BufferA.glsl"
#iChannel1 "file://KeyboardBuffer.glsl"
#include "Common.glsl"


float traceSphere(Ray ray, Sphere sphere) {
    vec3 L = sphere.center - ray.origin;

    float tca = dot(L, ray.direction);
    if (tca < 0.0) {
        return -1.0;
    } 

    float d = dot(L, L) - tca * tca;
    float r2 = sphere.radius * sphere.radius;
    if (d > r2) {
        return -1.0;
    }

    float thc = sqrt(r2 - d);

    float t0 = tca - thc;
    float t1 = tca + thc;

    if (t0 < 0.0) {
        if (t1 < 0.0) {
            return -1.0;
        }
        return t1;
    } else {
        if (t1 < 0.0) {
            return t0;
        }
        return min(t0, t1);
    }
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // TODO: THIS NEEDS TO GET THE CURRENT STATE STORED IN SOME BUFFER
    // INSTEAD OF RESETTING EVERY FRAME
    Camera camera = Camera_Get_Cached(iChannel1, iResolution);

    mat4 model, view, rotation;
    Camera_Model_View(camera, model, view, rotation);


    // Generate ray and transform to world space
    vec2 screen_coord = fragCoord / iResolution.xy;
    vec2 centered = vec2(screen_coord.x - 0.5, screen_coord.y - 0.5);

    float sensor_v = 2.0 * tan(Radians(camera.fov / 2.0));
    float sensor_h = camera.aspect_ratio * sensor_v;

    // In camera space, lies on plane at z = -1
    vec3 scaled = vec3(centered.x * sensor_h, centered.y * sensor_v, -1.0);
    Ray ray = Ray(vec3(0.0), normalize(scaled));
    Ray_Transform(ray, model);


    
    Sphere sphere = Sphere(vec3(0.0, 0.0, -3.), 2.0);
    float t = traceSphere(ray, sphere);
    if (t >= 0.0) {
        vec3 intersection_point = ray.origin + ray.direction * t;
        vec3 color_norm = normalize(intersection_point - sphere.center);

        color_norm = (color_norm + 1.) / 2.;
        fragColor = vec4(color_norm, 1.0);
        return;
    }

    
    fragColor = vec4(0.0,0.0,0.0,1.0);
}