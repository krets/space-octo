shader_type canvas_item;

uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float outline_width : hint_range(0, 10) = 3.0;

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    vec2 ps = TEXTURE_PIXEL_SIZE;

    float a;
    float maxa = col.a;

    // Use distance from center for smoother outline
    for(float x = -outline_width; x <= outline_width; x++) {
        for(float y = -outline_width; y <= outline_width; y++) {
            if (length(vec2(x, y)) <= outline_width) {  // Check if within circle radius
                vec2 offset = vec2(x, y) * ps;
                a = texture(TEXTURE, UV + offset).a;
                maxa = max(a, maxa);
            }
        }
    }

    vec4 final_color = mix(highlight_color, col, col.a);
    COLOR = mix(highlight_color, final_color, step(0.5, col.a));
    COLOR.a = smoothstep(0.05, 0.1, maxa);  // Smoother alpha transition
}