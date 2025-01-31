class_name RagdollBones extends PhysicalBoneSimulator3D

@onready var bone_push = $"Physical Bone hip";

var slappable : Slappable;

func ragdoll(slappable : Slappable, pos : Vector3, intensity : float):
	self.slappable = slappable;
	
	active = true;
	physical_bones_start_simulation();
	
	var to = global_position - pos;
	to.y = 0;
	bone_push.apply_impulse(to.normalized() * intensity, pos - global_position);
	
func slap(pos : Vector3, intensity : float, flash: bool):
	if !active:
		return;
	
	slappable.pre_slap(flash);
	
	var to = global_position - pos;
	to.y = 0;
	
	bone_push.apply_impulse(to.normalized() * intensity, pos - global_position);
