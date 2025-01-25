class_name Player extends CharacterBody3D


enum _Anim {
	FLOOR,
	AIR,
}

const SHOOT_TIME = 1.5
const SHOOT_SCALE = 2.0
const CHAR_SCALE = Vector3(0.3, 0.3, 0.3)
const MAX_SPEED = 6.0
const TURN_SPEED = 40.0
const JUMP_VELOCITY = 12.5
const BULLET_SPEED = 20.0
const AIR_IDLE_DEACCEL = false
const ACCEL = 14.0
const DEACCEL = 14.0
const AIR_ACCEL_FACTOR = 0.5
const SHARP_TURN_THRESHOLD = deg_to_rad(140.0)

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
	var move_dir_vec2 = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	
	var move_dir = _camera.global_basis * Vector3(move_dir_vec2.x, 0, move_dir_vec2.y);
	move_dir.y = 0;
	move_dir = move_dir.normalized();
	
	velocity = move_dir * 20;
	move_and_slide();
