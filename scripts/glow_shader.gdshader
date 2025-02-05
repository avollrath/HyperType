shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR = tex_color;

    // Add emission (glow effect)
    float intensity = tex_color.a;  // Use alpha as a base for glow
    vec3 glow_color = vec3(1.0, 0.5, 0.0) * intensity; // Adjust glow color
    COLOR.rgb += glow_color * 2.0;  // Increase emission strength
}