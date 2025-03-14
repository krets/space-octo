shader_type canvas_item;

uniform float crack_intensity = 0.0;
uniform vec2 crack_scale = vec2(10.0, 10.0);

void fragment() {
    vec2 uv = UV * crack_scale;
    float crack_pattern = sin(uv.x) * sin(uv.y);
    float crack = step(0.5, crack_pattern + crack_intensity);
    vec4 base_color = vec4(1.0); // White color
    vec4 crack_color = vec4(0.0); // Black cracks
    COLOR = mix(base_color, crack_color, crack);
}