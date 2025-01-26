class_name Enemy extends Area3D

@onready var bones : PhysicalBoneSimulator3D = $Skeleton3D/PhysicalBoneSimulator3D;

@onready var model : Mesh = $Skeleton3D/Robot.mesh;
func flash(on : bool) -> void:
	var c = model.get_surface_count();
	for i in c:
		var mat = model.surface_get_material(i);
		if mat is StandardMaterial3D:
			mat.emission_enabled = on;
			if on:
				mat.emission = Color.WHITE;
				mat.emission_energy_multiplier = 100.0;

func ragdoll(pos):
	flash(true);
	var pauser : Pauser = get_tree().current_scene.get_node("Pauser");
	pauser.on_unpause.connect(flash.bind(false), CONNECT_ONE_SHOT);
	pauser.pause();
	
	$CollisionShape3D.disabled = true;
	bones.physical_bones_start_simulation();
	var bone : PhysicalBone3D = bones.get_node("Physical Bone hip");
	
	var to = global_position - pos;
	to.y = 0;
	bone.apply_impulse(to.normalized() * 500, pos);
