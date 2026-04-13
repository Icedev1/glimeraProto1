shader_type canvas_item;

uniform float fade : hint_range(0.0, 1.0, 0.05) = 0.0;
uniform float center_x: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float center_y: hint_range(0.0, 1.0, 0.01) = 0.5;

void fragment() {
	vec2 center = vec2(center_x, center_y);
	vec2 vec = UV - center;
	float angle = atan(vec.y, vec.x);
	if (angle < 0.0) angle += 2.0 * PI;
	angle /= 2.0 * PI;
	
	angle -= 0.75;
	if (angle < 0.0) angle += 1.0;
	
	float progress = step(angle,fade);
	
	COLOR.a *= progress;

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
