class_name Enemy extends Area3D

@onready var bones : PhysicalBoneSimulator3D = $Skeleton3D/PhysicalBoneSimulator3D;

func ragdoll(pos):
	get_tree().current_scene.get_node("Pauser").pause();
	$CollisionShape3D.disabled = true;
	bones.physical_bones_start_simulation();
	var bone : PhysicalBone3D = bones.get_node("Physical Bone hip");
	
	var to = global_position - pos;
	to.y = 0;
	bone.apply_impulse(to.normalized() * 500, pos);
