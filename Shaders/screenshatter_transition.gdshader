shader_type canvas_item;

// Built-in screen texture (Godot 4.6 way)
uniform sampler2D screen_texture : hint_screen_texture;

uniform float time = 0.0;
uniform float piece_scale = 12.0;
uniform float explosion = 1.5;
uniform float fade_speed = 1.2;

float rand(vec2 p){
    return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453);
}

vec2 random_vec(vec2 p){
    return vec2(rand(p), rand(p + 1.23));
}

void fragment(){

    vec2 uv = SCREEN_UV;

    // Voronoi grid
    vec2 grid = floor(uv * piece_scale);
    vec2 local = fract(uv * piece_scale);

    float min_dist = 10.0;
    vec2 closest = vec2(0.0);

    for(int y = -1; y <= 1; y++){
        for(int x = -1; x <= 1; x++){

            vec2 cell =
                vec2(float(x), float(y));

            vec2 point =
                random_vec(grid + cell);

            vec2 diff =
                cell + point - local;

            float dist = length(diff);

            if(dist < min_dist){
                min_dist = dist;
                closest = grid + cell;
            }
        }
    }

    // Random fragment direction
    vec2 dir =
        normalize(random_vec(closest) - 0.5);

    // Per-piece delay
    float delay =
        rand(closest) * 0.3;

    float t =
        max(0.0, time - delay);

    // Explosion movement
    vec2 offset =
        dir * t * explosion;

    // Gravity
    offset.y += t * t * 0.6;

    vec2 final_uv =
        uv - offset;

    vec4 col =
        texture(screen_texture, final_uv);

    // Fade pieces
    float alpha =
        clamp(1.0 - time * fade_speed, 0.0, 1.0);

    COLOR =
        vec4(col.rgb, col.a * alpha);
}