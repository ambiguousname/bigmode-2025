class_name Enemy extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D;

@onready var player : Player = get_tree().current_scene.get_node("Player");

@onready var bones : RagdollBones = $enemy_mesh/Skeleton3D/PhysicalBoneSimulator3D;

@onready var anim_tree : AnimationTree = $AnimationTree;

@onready var slappable : Slappable = $SlappableManager;

func _ready() -> void:
	slappable.init($enemy_mesh/Skeleton3D/Sphere);

func slap_behavior():
	pass

var slapped : bool = false;

func slap(pos, intensity, flash):
	slappable.pre_slap(flash);
	
	velocity = Vector3.ZERO;
	
	slap_behavior();
	
	slapped = true;
	$CollisionShape3D.disabled = true;
	
	bones.ragdoll(slappable, pos, intensity);

func eval_behavior(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if slapped:
		return;
	eval_behavior(delta);
	
	move_and_slide();
