shader_type canvas_item;

uniform vec4 planet_color = vec4(0.2, 0.6, 1.0, 1.0);
uniform float noise_scale = 3.0;
uniform float shading_strength = 0.8;
uniform float glow_intensity = 0.4;

// Better noise function
float rand(vec2 coord) {
    return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 coord) {
    vec2 i = floor(coord);
    vec2 f = fract(coord);

    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    vec2 cubic = f * f * (3.0 - 2.0 * f);

    return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

// Fractal Brownian Motion
float fbm(vec2 coord) {
    float value = 0.0;
    float scale = 0.5;

    for(int i = 0; i < 6; i++) {
        value += noise(coord) * scale;
        coord *= 2.0;
        scale *= 0.5;
    }
    return value;
}

void fragment() {
    vec2 uv = UV * 2.0 - 1.0;
    float dist = length(uv);

    if (dist > 1.0) {
        discard;
    }

    // Calculate sphere normal for better lighting
    vec3 normal = normalize(vec3(uv, sqrt(1.0 - dist * dist)));

    // Create varied surface detail using FBM
    float surface_detail = fbm(uv * noise_scale);

    // Better lighting with normal-based shading
    vec3 light_dir = normalize(vec3(-0.5, 0.5, 1.0));
    float diffuse = max(0.0, dot(normal, light_dir));

    // Combine lighting with surface detail
    float shading = mix(diffuse, surface_detail, 0.3) * shading_strength;
    shading = clamp(shading + 0.2, 0.0, 1.0);  // Add ambient light

    // Atmospheric glow
    float atmosphere = 1.0 - smoothstep(0.8, 1.0, dist);
    float glow = smoothstep(0.7, 1.0, dist) * glow_intensity;

    // Final color
    vec3 color = planet_color.rgb * shading;
    color += planet_color.rgb * glow * 0.5;  // Add glow
    color *= atmosphere;  // Apply atmosphere falloff

    COLOR = vec4(color, 1.0);
}