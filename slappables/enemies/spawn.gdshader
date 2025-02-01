shader_type spatial;
render_mode unshaded;

uniform float progress = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 new_uv = UV - vec2(0.5, 0.5);
	float eval = abs(new_uv.x) + abs(new_uv.y);
	float prog = 1.0 - step(progress, eval);
	float prog1 =  (step(progress - 0.01, eval));
	ALPHA = prog;
	ALBEDO = vec3(prog1, prog1, prog1);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
