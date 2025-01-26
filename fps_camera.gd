extends Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	
	get_tree().current_scene.get_node("Pauser").on_unpause.connect(clear_shake);

var mouse_move_intent : Vector2;
var mouse_move_intent_intensity : float = 0;
@onready var hand_target : Node3D = $hand/Target;
@onready var hand_trigger : Area3D = $hand/Root/Skeleton3D/HandEnd/HandEndTrigger;
@onready var hand_mat : StandardMaterial3D = $hand/Root/Skeleton3D/Cube.material_override;

@onready var player : Player = get_parent();

@onready var base_pos : Vector3 = position;

@onready var ui : UIManager = get_tree().current_scene.get_node("CanvasLayer");

var shooting : bool = false;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_move_intent += event.relative;
		mouse_move_intent_intensity += event.relative.length();
	
	if event.is_action("shoot"):
		shooting = event.get_action_strength("shoot") > 0.5;

func _process(delta: float) -> void:
	calc_shake();
	
	get_input(delta);

var shoot_move_intent : Vector3 = Vector3.ZERO;

func get_input(delta : float):
	var rot : Vector2 = mouse_move_intent * delta/10;
	
	if shooting:
		hand_target.position += Vector3(rot.x, -rot.y, 0);
		
		hand_target.position = hand_target.position.clamp(Vector3(-3.8, -1, hand_target.position.z), Vector3(2.5, 2, hand_target.position.z));
		
		if hand_target.position.x < -2.7:
			shoot_move_intent.y += delta;
		elif hand_target.position.x > 1.1:
			shoot_move_intent.y -= delta;
		
		if mouse_move_intent_intensity > 300:
			var dir = Vector3(-mouse_move_intent.x, mouse_move_intent.y, 0).normalized();
			var hit_from = global_position + global_basis * dir;
			for b in hand_trigger.get_overlapping_areas():
				if b is Enemy:
					ui.inc_combo();
					curr_shake += 0.4;
					b.ragdoll(hit_from, mouse_move_intent_intensity);
			hand_mat.albedo_color = lerp(hand_mat.albedo_color, Color.RED, min(delta * mouse_move_intent_intensity/50, 1.0));
		else:
			hand_mat.albedo_color = lerp(hand_mat.albedo_color, Color.BLACK, delta * 10);
		
		rotation += shoot_move_intent;
	else:
		hand_mat.albedo_color = Color.BLACK;
		rotation.x -= rot.y;
		
		player.rotation.y -= rot.x;
	
	rotation.x = clampf(rotation.x, -PI/2 + 0.01, PI/2 - 0.01);
	
	mouse_move_intent *= 0.2;
	mouse_move_intent_intensity *= 0.5;
	shoot_move_intent *= 0.8;

var curr_shake : float = 0.0;

func clear_shake():
	curr_shake *= 0.5;

func calc_shake():
	var shake = pow(curr_shake, 2);
	rotation.z = (PI/4) * shake * randf_range(-1, 1);
	position.x = base_pos.x + shake * randf_range(-1, 1);
	position.y = base_pos.y + shake * randf_range(-1, 1);
	curr_shake *= 0.95;
