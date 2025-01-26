class_name RigidbodyTrigger extends Area3D

@onready var bones : PhysicalBoneSimulator3D = get_parent().get_node("Skeleton3D/PhysicalBoneSimulator3D");

func activate():
	bones.physical_bones_start_simulation();
