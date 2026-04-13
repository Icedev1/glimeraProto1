shader_type spatial;

uniform float flash_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec3 flash_color = vec3(1.0, 1.0, 0.0);

void fragment() {
	// Base lighting comes from existing material (or albedo if standalone)
	vec3 base_color = ALBEDO;

	// Flash effect (additive mix)
	vec3 final_color = mix(base_color, flash_color, flash_intensity);

	ALBEDO = final_color;
}