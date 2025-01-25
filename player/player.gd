class_name Player extends CharacterBody3D

const FRICTION = 0.8;

var movement_dir := Vector3()
var jumping := false
var prev_shoot := false
var shoot_blend := 0.0

# Number of coins collected.
var coins := 0

@onready var initial_position := position
@onready var gravity: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity") * \
		ProjectSettings.get_setting("physics/3d/default_gravity_vector")

@onready var _camera := $Camera3D as Camera3D


func _physics_process(delta: float) -> void:
	velocity *= FRICTION;
	
	var move_dir_vec2 = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	
	var move_dir = _camera.global_basis * Vector3(move_dir_vec2.x, 0, move_dir_vec2.y);
	move_dir.y = 0;
	move_dir = move_dir.normalized();
	
	velocity += move_dir;
	move_and_slide();
