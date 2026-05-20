shader_type spatial;

uniform float saturation = 0.7;
uniform float brightness = 0.8;

float hash(vec3 p) {
    return fract(sin(dot(p, vec3(12.9898,78.233,45.164))) * 43758.5453);
}

vec3 hsv2rgb(vec3 c) {
    vec3 rgb = clamp(
        abs(mod(c.x * 6.0 + vec3(0.0,4.0,2.0),6.0)-3.0)-1.0,
        0.0,
        1.0
    );

    rgb = rgb * rgb * (3.0 - 2.0 * rgb);

    return c.z * mix(vec3(1.0), rgb, c.y);
}

void fragment() {

    // Use object world position as random seed
    float h = hash(NODE_POSITION_WORLD);

    vec3 color = hsv2rgb(vec3(
        h,            // random hue
        saturation,
        brightness
    ));

    ALBEDO = color;
}