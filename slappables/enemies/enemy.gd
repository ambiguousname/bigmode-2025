class_name Enemy extends CharacterBody3D

@export var override_mat : Material;

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D;

@onready var player : Player = get_tree().current_scene.get_node("Player");

@onready var bones : RagdollBones = $enemy_mesh/Skeleton3D/PhysicalBoneSimulator3D;

@onready var anim_tree : AnimationTree = $AnimationTree;

@onready var slappable : Slappable = $SlappableManager;

@onready var spawn_portal : MeshInstance3D = $SpawnPortal;
@onready var spawn_portal_mat : ShaderMaterial = spawn_portal.mesh.surface_get_material(0);
@onready var animation_player : AnimationPlayer = $enemy_mesh/AnimationPlayer;

@onready var mesh = $enemy_mesh/Skeleton3D/Sphere;

func _ready() -> void:
	if override_mat != null:
		mesh.set_surface_override_material(0, override_mat);
	slappable.init(mesh, Slappable.SFXType.Fleshy);

func slap_behavior():
	pass

var slapped : bool = false;
var enabled : bool = false;

func slap(pos, intensity, flash):
	if !enabled:
		return;
	slappable.pre_slap(flash, intensity);
	
	velocity = Vector3.ZERO;
	
	slap_behavior();
	
	slapped = true;
	$CollisionShape3D.set.call_deferred("disabled", true);
	
	bones.ragdoll(slappable, pos, intensity);

func eval_behavior(delta: float) -> void:
	pass
	
var spawn_dir : int = 0;
var spawn_prog : float = 0.0;

func spawn():
	spawn_portal.visible = true;
	spawn_dir = 1;
	anim_tree.set("parameters/conditions/spawn", true);

func _process(delta: float) -> void:
	if spawn_dir > 0:
		spawn_prog += delta * 0.8;
		spawn_portal_mat.set_shader_parameter("progress", spawn_prog);
		
		if spawn_prog >= 0.5:
			spawn_prog = 0.5;
			spawn_dir = -1;
	elif spawn_dir < 0:
		spawn_prog -= delta;
		spawn_portal_mat.set_shader_parameter("progress", spawn_prog);
		if spawn_prog <= 0:
			enabled = true;
			spawn_dir = 0;
			spawn_portal.visible = false;

func _physics_process(delta: float) -> void:
	if !enabled or slapped:
		return;
	eval_behavior(delta);
	
	move_and_slide();
