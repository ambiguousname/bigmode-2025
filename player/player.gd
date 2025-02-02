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

@onready var pain : AudioStreamPlayer3D = $Pain;

@onready var raycast : RayCast3D = $RayCast3D;
@onready var shapecast : ShapeCast3D = $ShapeCast3D;

func _ready() -> void:
	var res = CheckpointManager.get_respawn_point();
	if res[0] != Vector3.ZERO:
		global_position = res[0];
		global_rotation = res[1];

var jump : float;
var jumping : bool = false;

var slam : float;
var is_slamming : bool = false;
var slam_dist : float = 0;
func _input(event: InputEvent) -> void:
	if event.is_action("jump"):
		jump = event.get_action_strength("jump");
	if event.is_action("slam"):
		slam = event.get_action_strength("slam");

func _physics_process(delta: float) -> void:
	if global_position.y < -12:
		var res = CheckpointManager.get_respawn_point();
		if res[0] != Vector3.ZERO:
			initial_position = res[0];
			is_slamming = false;
			_camera.curr_shake = 0;
			slam_dist = 0;
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
	
	if is_slamming:
		if !is_on_floor():
			if velocity.y > 0:
				velocity.y = 0;
			velocity += Vector3.DOWN * JUMP_STR;
			_camera.curr_shake += 0.05;
			slam_dist -= velocity.y * delta;
		else:
			is_slamming = false;
			shapecast.enabled = true;
			shapecast.shape.radius = slam_dist;
			shapecast.force_shapecast_update();
			pauser.pause(0.5);
			for i in shapecast.get_collision_count():
				var c = shapecast.get_collider(i);
				if (c is SlappableObj or c is Enemy):
					_camera.slap_thing(c, slam_dist * 100, global_position);
				elif c.get("collision_layer") == 0b10:
					_camera.slap_thing(c.get_parent(), slam_dist * 100, global_position);
			shapecast.enabled = false;
			slam = 0;
			slam_dist = 0;
	
	var c = raycast.get_collision_point();
	if !is_slamming:
		if (!raycast.is_colliding() or (raycast.get_collider() != null and c.distance_to(global_position) > 10)):
			ui.show_slam();
			if slam > 0.5:
				is_slamming = true;
				ui.hide_slam();
		else:
			ui.hide_slam();
	
	velocity += move_dir;
	move_and_slide();

var health : float = 100;

func damage(hp : float):
	health -= hp;
	_camera.curr_shake += 0.2;
	ui.set_health(health);
	
	if hp >= 20:
		pain.play();
	
	if health <= 0:
		_camera.curr_shake = 0.5;
		pauser.pause();
		pauser.on_unpause.connect(ui.die, CONNECT_ONE_SHOT);

func _process(delta: float) -> void:
	if ui.combo_count > 0:
		health += 10 * delta * (log(ui.combo_count) + 1);
		health = min(health, 100);
		ui.set_health(health);
