shader_type spatial;
render_mode unshaded;
uniform float flash_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec3 flash_color = vec3(1.0, 0.2, 0.2);
void fragment() {
	ALBEDO = flash_color;
	ALPHA = flash_intensity;
}