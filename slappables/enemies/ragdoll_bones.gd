class_name RagdollBones extends PhysicalBoneSimulator3D

@onready var bone_push = $"Physical Bone Spine";

var slappable : Slappable;

const INTENSITY_MUL : float = 0.5;

func ragdoll(slappable : Slappable, pos : Vector3, intensity : float):
	self.slappable = slappable;
	
	active = true;
	physical_bones_start_simulation();
	
	var to = bone_push.global_position - pos;
	to.y = 0;
	bone_push.apply_impulse(to.normalized() * intensity * INTENSITY_MUL, pos - bone_push.global_position);
	
func slap(pos : Vector3, intensity : float, flash: bool):
	if !active:
		return;
	
	slappable.global_position = global_position;
	slappable.pre_slap(flash, intensity);
	
	var to = bone_push.global_position - pos;
	to.y = 0;
	
	bone_push.apply_impulse(to.normalized() * intensity * INTENSITY_MUL, pos - bone_push.global_position);
