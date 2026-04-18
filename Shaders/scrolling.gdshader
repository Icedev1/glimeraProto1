shader_type canvas_item;

uniform vec2 scroll_speed = vec2(0.1, 0.0);

void fragment() {
    vec2 uv = UV;
    uv += scroll_speed * TIME;
    COLOR = texture(TEXTURE, uv);
}