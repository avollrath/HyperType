shader_type canvas_item;

uniform bool apply;
uniform float amount;
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 color = texture(screen_texture, uv);
    
    if (apply) {
        float adjusted_amount = amount / 100.0;
        color.r = texture(screen_texture, vec2(uv.x + adjusted_amount, uv.y)).r;
        color.g = texture(screen_texture, uv).g;
        color.b = texture(screen_texture, vec2(uv.x - adjusted_amount, uv.y)).b;
    }
    COLOR = color;
}