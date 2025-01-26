class_name Enemy extends Area3D

@onready var bones : PhysicalBoneSimulator3D = $Skeleton3D/PhysicalBoneSimulator3D;

var flash_mat : Material = preload("res://ragdolls/flash.tres");

@onready var mesh : MeshInstance3D = $Skeleton3D/Robot;

func flash(on : bool) -> void:
	if on:
		mesh.material_override = flash_mat;
	else:
		mesh.material_override = null;

func ragdoll(pos, intensity):
	flash(true);
	var pauser : Pauser = get_tree().current_scene.get_node("Pauser");
	pauser.on_unpause.connect(flash.bind(false), CONNECT_ONE_SHOT);
	pauser.pause();
	
	$CollisionShape3D.disabled = true;
	bones.physical_bones_start_simulation();
	var bone : PhysicalBone3D = bones.get_node("Physical Bone hip");
	
	var to = global_position - pos;
	to.y = 0;
	bone.apply_impulse(to.normalized() * intensity, pos);
