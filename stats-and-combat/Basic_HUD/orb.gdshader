shader_type canvas_item;

uniform vec4 red_color = vec4(1, 0, 0, 1);
uniform float radius = .7;
uniform float health = .7;


void vertex() {
	// Called for every vertex the material is visible on.
}


void fragment() {
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, center);
	if ( dist <= radius && UV.y > health) {
		COLOR = red_color;
	}
	
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
