class_name Player extends CharacterBody3D

const AIR_FRICTION = 0.8;
const FRICTION = 0.85;
const JUMP_STR = 5;

# TODO: Health, health recharges based on combo?

@onready var initial_position := position;
@onready var gravity: Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity") * \
		ProjectSettings.get_setting("physics/3d/default_gravity_vector");

@onready var _camera : FPSCamera = $Camera3D;

@onready var ui : UIManager = get_tree().current_scene.get_node("CanvasLayer");

@onready var pauser : Pauser = get_tree().current_scene.get_node("Pauser");

var jump : float;
var jumping : bool = false;
func _input(event: InputEvent) -> void:
	if event.is_action("jump"):
		jump = event.get_action_strength("jump");

func _physics_process(delta: float) -> void:
	if global_position.y < -12:
		position = initial_position;
		velocity = Vector3.ZERO;
		
	if is_on_floor():
		velocity *= FRICTION;
	else:
		velocity.x *= AIR_FRICTION;
		velocity.z *= AIR_FRICTION;
	
	var grav_str = 1.0;
	if velocity.y < 0:
		grav_str = 1.5;
	velocity += gravity * delta * grav_str;
	
	var move_dir_vec2 = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	
	var move_dir = _camera.global_basis * Vector3(move_dir_vec2.x, 0, move_dir_vec2.y);
	move_dir.y = 0;
	move_dir = move_dir.normalized();
	
	
	if jumping and velocity.y <= 0 and is_on_floor():
		jumping = false;
	
	if jump > 0.5 and is_on_floor() and not jumping:
		move_dir += Vector3.UP * JUMP_STR;
		jumping = true;
	
	velocity += move_dir;
	move_and_slide();

var health : float = 100;

func damage(hp : float):
	health -= hp;
	_camera.curr_shake += 0.2;
	ui.set_health(health);
	
	if health <= 0:
		_camera.curr_shake = 0.5;
		pauser.pause();
		pauser.on_unpause.connect(ui.die, CONNECT_ONE_SHOT);

func _process(delta: float) -> void:
	if ui.combo_count > 0:
		health += 10 * delta * (log(ui.combo_count) + 1);
		health = min(health, 100);
		ui.set_health(health);
