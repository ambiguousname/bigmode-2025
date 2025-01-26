class_name Enemy extends Area3D

@onready var bones : PhysicalBoneSimulator3D = $Skeleton3D/PhysicalBoneSimulator3D;

func reset_mats():
	var rob : Mesh = $Skeleton3D/Robot.mesh;
	var c = rob.get_surface_count();
	for i in c:
		var mat : StandardMaterial3D = rob.surface_get_material(i);
		mat.emission_enabled = false;

func ragdoll(pos):
	var rob : Mesh = $Skeleton3D/Robot.mesh;
	var c = rob.get_surface_count();
	for i in c:
		var mat : StandardMaterial3D = rob.surface_get_material(i);
		mat.emission_enabled = true;
		mat.emission = Color.WHITE;
		mat.emission_energy_multiplier = 100.0;
	var pauser : Pauser = get_tree().current_scene.get_node("Pauser");
	pauser.on_unpause.connect(reset_mats, CONNECT_ONE_SHOT);
	pauser.pause();
	
	$CollisionShape3D.disabled = true;
	bones.physical_bones_start_simulation();
	var bone : PhysicalBone3D = bones.get_node("Physical Bone hip");
	
	var to = global_position - pos;
	to.y = 0;
	bone.apply_impulse(to.normalized() * 500, pos);
