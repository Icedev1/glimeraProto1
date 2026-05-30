shader_type spatial;
render_mode blend_add;

uniform vec3 aura_color : source_color = vec3(0.3, 1.0, 0.4);
uniform float progress : hint_range(0.0, 1.0) = 1.0;
uniform float stripe_density : hint_range(0.0, 30.0) = 11.0;
uniform float scroll_amount : hint_range(0.0, 30.0) = 14.0;

varying float v_height;

void vertex() {
    // World-space height of this vertex
    v_height = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y;
}

void fragment() {
    // fast movement first 80% then freeze
    float scroll_t = clamp(progress / 0.8, 0.0, 1.0);
    float scroll = 1.0 - pow(1.0 - scroll_t, 3.0);

    // Horizontal bands rising up the body 
    float stripes = sin(v_height * stripe_density - scroll * scroll_amount) * 0.5 + 0.5;

    // Fade out over the last 50% of progress
    float fade = 1.0 - smoothstep(0.5, 1.0, progress);

    ALBEDO = aura_color * stripes * fade;
}
