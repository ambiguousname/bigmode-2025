class_name Enemy extends Area3D

@onready var bones : PhysicalBoneSimulator3D = $Skeleton3D/PhysicalBoneSimulator3D;

@onready var slappable : Slappable = $SlappableManager;

func _ready() -> void:
	slappable.init($Skeleton3D/Cube);

func slap(pos, intensity):
	slappable.pre_slap();
	
	$CollisionShape3D.disabled = true;
	bones.physical_bones_start_simulation();
	var bone : PhysicalBone3D = bones.get_node("Physical Bone hip");
	
	var to = global_position - pos;
	to.y = 0;
	bone.apply_impulse(to.normalized() * intensity, pos - global_position);
