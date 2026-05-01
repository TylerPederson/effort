shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float pixel_size = 4.0;
uniform float color_levels = 5.0;
uniform float dither_strength = 0.03;
uniform float jitter_strength = 0.0015;
uniform float scanline_strength = 0.04;

float bayer4(vec2 p) {
    int x = int(mod(p.x, 4.0));
    int y = int(mod(p.y, 4.0));
    int index = x + y * 4;

    float[16] mat = float[](
        0.0,  8.0,  2.0, 10.0,
        12.0, 4.0, 14.0, 6.0,
        3.0, 11.0,  1.0,  9.0,
        15.0, 7.0, 13.0,  5.0
    );

    return mat[index] / 16.0;
}

void fragment() {
    vec2 uv = SCREEN_UV;

    vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 lowres = floor(uv * screen_size / pixel_size) * pixel_size;
    uv = lowres / screen_size;

    vec4 col = textureLod(screen_texture, uv, 0.0);

    float dither = (bayer4(FRAGCOORD.xy) - 0.5) * dither_strength;
    col.rgb += dither;

    col.rgb = floor(col.rgb * color_levels) / color_levels;


    COLOR = vec4(col.rgb, 1.0);
}