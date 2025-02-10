shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;

const float curvature = 8.0;
const float vignette_multiplier = 0.2;
const float blur_amount = 0.15;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

vec3 blur(sampler2D tex, vec2 uv, vec2 scale) {
   vec3 col = vec3(0.0);
   float total = 0.0;
   
   for(float x = -2.0; x <= 2.0; x += 1.0) {
       for(float y = -2.0; y <= 2.0; y += 1.0) {
           vec2 offset = vec2(x, y) * scale;
           float weight = 1.0 - length(offset) * 0.25;
           col += texture(tex, uv + offset).rgb * weight;
           total += weight;
       }
   }
   
   return col / total;
}

void fragment() {
   vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
   vec2 uv_offset = centered_uv.yx / curvature;
   vec2 warped_uv = centered_uv + centered_uv * uv_offset * uv_offset;
   vec3 cutoff = vec3(step(abs(warped_uv.x), 1.0) * step(abs(warped_uv.y), 1.0));
   vec3 scanlines = vec3(sin(2.0 * warped_uv.y * 450.0) * 0.1 + 0.98);
   vec3 vignette = vec3(length(pow(abs(centered_uv), vec2(4.0)) / 3.0));
   
   vec2 final_uv = (warped_uv + 1.0) / 2.0;
   vec3 screen_color = blur(screen_texture, final_uv, vec2(0.001 * blur_amount)) * cutoff * scanlines;
   screen_color -= vignette * vignette_multiplier;
   COLOR = vec4(screen_color, 1.0);
}