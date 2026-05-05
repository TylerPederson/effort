shader_type spatial;

uniform vec3 color1 = vec3(0.9, 0.225, 0.65);
uniform vec3 color2 = vec3(0.9, 0.2, 0.2);
uniform float blend_factor : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	ALBEDO = mix(color1, color2, blend_factor);
	EMISSION = vec3(1,0,0) * 30.0 * blend_factor;
}
