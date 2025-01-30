class_name Enemy extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D;

@onready var player : Player = get_tree().current_scene.get_node("Player");

@onready var bones : PhysicalBoneSimulator3D = $Skeleton/Skeleton3D/PhysicalBoneSimulator3D;

@onready var anim_tree : AnimationTree = $AnimationTree;

@onready var slappable : Slappable = $SlappableManager;

func _ready() -> void:
	slappable.init($Skeleton/Skeleton3D/Robot);

func slap_behavior():
	pass

func slap(pos, intensity, flash):
	slappable.pre_slap(flash);
	
	velocity = Vector3.ZERO;
	
	slap_behavior();
	
	$CollisionShape3D.disabled = true;
	
	bones.active = true;
	bones.physical_bones_start_simulation();
	var bone : PhysicalBone3D = bones.get_node("Physical Bone hip");
	
	var to = global_position - pos;
	to.y = 0;
	bone.apply_impulse(to.normalized() * intensity, pos - global_position);

func eval_behavior(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	eval_behavior(delta);
	
	move_and_slide();
