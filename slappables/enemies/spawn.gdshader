shader_type spatial;
render_mode unshaded;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 new_uv = UV - vec2(0.5, 0.5);
	ALPHA = step(0, pow(cos(new_uv.x), 2) + pow(sin(new_uv.y), 2));
	ALBEDO = vec3(0, 0, 0);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
