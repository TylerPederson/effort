shader_type canvas_item;

uniform vec4 color_full = vec4(0, 1, 0, 1);
uniform vec4  color_empty = vec4(1, 1, 1, 1);
uniform vec4 rim_color = vec4 (1,1,1,1);
uniform float radius = .1;
uniform float health = .1;
uniform float darkness : hint_range(0.0, 1.0) = 0.5;
uniform float rim_darkness : hint_range(0.0, 5.0) = .5;

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
	float rim = smoothstep(radius - 0.02, radius, dist);
	float light = 1.0 - dist*.9;
	
	float liquid = step(UV.y + wave, fill_line);
	vec4 col = mix(color_empty, color_full, liquid);
	col.rgb *= light;
	col.rgb *= .8 - darkness * dist;
	col.rgb += rim *rim_color.rgb * darkness;
	col.a *=circle;
	
	
	
	

	COLOR = col;
	
}
