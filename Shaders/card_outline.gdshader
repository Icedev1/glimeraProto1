shader_type canvas_item;
uniform vec4 outline_color : source_color = vec4(0.3, 1.0, 0.4, 1.0);
uniform float thickness : hint_range(0.001, 0.3) = 0.2;
uniform float solid_thickness : hint_range(0.0, 0.1) = 0.015;
uniform float corner_radius : hint_range(0.0, 0.5) = 0.03;
uniform float pulse_speed : hint_range(0.0, 10.0) = 3;
void fragment() {
    vec2 p = UV - 0.5;                                            
    vec2 q = abs(p) - (vec2(0.5) - corner_radius);               
    float sdf = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - corner_radius;
    float inside = 1.0 - smoothstep(0.0, 0.002, sdf);             
    float dist = max(-sdf, 0.0);                                  
    float t = clamp(dist / thickness, 0.0, 1.0);                  
    float edge = (1.0 - t) * (1.0 - t);                           
    // Pulse kept in 0.3..1.0 so the band never fully blinks off
    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
    pulse = pulse * 0.7 + 0.3;
    float glow_a = edge * pulse * outline_color.a;                
    // Solid edge, always-on
    float solid = 1.0 - smoothstep(solid_thickness, solid_thickness + 0.002, dist);
    float a = max(glow_a, solid * outline_color.a) * inside;     
    vec3 rgb = mix(COLOR.rgb, outline_color.rgb, a);              
    COLOR = vec4(rgb, max(COLOR.a, a));                           
}