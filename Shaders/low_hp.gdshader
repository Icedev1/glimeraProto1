shader_type canvas_item;

uniform float hp_ratio : hint_range(0.0, 1.0) = 1.0;
uniform float threshold : hint_range(0.0, 1.0) = 0.4;
uniform vec4 pulse_color : source_color = vec4(0.7, 0.0, 0.0, 1.0);
uniform float pulse_speed : hint_range(0.0, 10.0) = 4.0;
uniform sampler2D screen_texture : hint_screen_texture ;


void fragment() {
    vec4 base = texture(screen_texture, SCREEN_UV); 
    float low_hp_mask = 1.0 - smoothstep(0.0, threshold, hp_ratio);
    float dist = length(SCREEN_UV - vec2(0.5));

    // pulse kept in 0.5..1.0 so the pulse never fully blinks off 
    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
    pulse = pulse * 0.4 + 0.4;

    float strength = dist * low_hp_mask * pulse;
    COLOR = mix(base, vec4(pulse_color.rgb, 1.0), (strength * 2.0) * pulse_color.a);
}