shader_type canvas_item;
render_mode blend_add;

// Set by tutorial_overlay.gd each time a highlight is shown.
uniform vec2 inner_size = vec2(100.0);
uniform vec2 outer_size = vec2(200.0);

const vec3 GLOW_COLOR = vec3(1.0, 0.95, 0.2); // yellow
const float BRIGHTEN = 0.3;     // lifts the inside back over the 0.3 dim
const float GLOW_RADIUS = 24.0; // pixels the glow extends outward

void fragment() {
	vec2 pixel = UV * outer_size - outer_size * 0.5;
	vec2 d = abs(pixel) - inner_size * 0.5;
	float dist = length(max(d, vec2(0.0))) + min(max(d.x, d.y), 0.0);

	// Brighten inside the rect.
	float brighten = (1.0 - smoothstep(-1.0, 1.0, dist)) * BRIGHTEN;

	// Yellow glow 
	float edge = smoothstep(-1.0, 1.0, dist);
	float falloff = 1.0 - smoothstep(0.0, GLOW_RADIUS, dist);
	float glow = edge * falloff;

	COLOR = vec4(vec3(brighten) + GLOW_COLOR * glow, 1.0);
}
