shader_type canvas_item;

uniform float crack_density = 10.0;
uniform float crack_width = 0.05;
uniform vec4 crack_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float noise_scale = 20.0;
uniform float crack_roughness = 2.0;

// Simple 2D noise function
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

// 2D noise based on random function
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

// Voronoi noise for crack pattern
float voronoi(vec2 st) {
    vec2 i_st = floor(st);
    vec2 f_st = fract(st);

    float min_dist = 1.0;

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = random(i_st + neighbor);
            point = 0.5 + 0.5 * sin(6.2831 * point);
            vec2 diff = neighbor + point - f_st;
            float dist = length(diff);
            min_dist = min(min_dist, dist);
        }
    }

    return min_dist;
}

void fragment() {
    // Use SCREEN_UV instead of UV for better positioning
    vec2 scaled_uv = SCREEN_UV * noise_scale;

    // Generate crack pattern
    float v = voronoi(scaled_uv);
    float n = noise(scaled_uv * crack_roughness);

    // Create cracks
    float cracks = step(v, crack_width + n * 0.1);

    // Mix base color with crack color
    COLOR = mix(base_color, crack_color, cracks * crack_density);
}