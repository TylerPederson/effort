shader_type canvas_item;

uniform vec4 color_full = vec4(1, 0, 0, 1);
uniform vec4  color_empty = vec4(1, 0.0, 0.0, 1);
uniform vec4 rim_color = vec4 (0,1,1,1);
uniform float darkness : hint_range(0.0, 1.0) = 0.5;

uniform float radius = .1;
uniform float health = .7;
uniform float edge_softness = 0.01;
uniform float wave_strength = 0.02;
uniform float wave_speed = 2.0;


void vertex() {
	// Called for every vertex the material is visible on.
}


void fragment() {
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center);
	float circle = smoothstep(radius, radius - edge_softness, dist);
	float wave = sin((UV.x + TIME * wave_speed) * 10.0) * wave_strength;

	float fill_line = (1.0 - health);

	float liquid = step(UV.y + wave, fill_line);
	vec4 col = mix(color_full,color_empty, liquid);
	col.rgb *= .8 - darkness * dist;
	col.a *=circle;



	if (dist > radius) {
		discard;
	}
	COLOR = col;

}