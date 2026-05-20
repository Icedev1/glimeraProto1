shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 10.0) = 3.0;
uniform float darkness : hint_range(0.0, 1.0) = 0.4;

void fragment() {
	vec2 pixel_size = SCREEN_PIXEL_SIZE;
	vec4 color = vec4(0.0);
	
	for (int x = -2; x <= 2; x++) {
		for (int y = -2; y <= 2; y++) {
			color += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(float(x), float(y)) * pixel_size * blur_amount);
		}
	}
	color /= 25.0;
	
	COLOR = vec4(color.rgb * (1.0 - darkness), 0.85);
}