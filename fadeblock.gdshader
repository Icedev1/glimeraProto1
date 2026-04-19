shader_type canvas_item;

uniform float fade_size : hint_range(0.0, 0.5) = 0.15;

void fragment() {
    vec2 uv = UV;

    // Distance to closest edge
    float dist_x = min(uv.x, 1.0 - uv.x);
    float dist_y = min(uv.y, 1.0 - uv.y);
    float dist = min(dist_x, dist_y);

    // Smooth fade
    float alpha = smoothstep(0.0, fade_size, dist);
	alpha = pow(alpha, 1.5);

    COLOR = vec4(COLOR.rgb, COLOR.a * alpha);
}