class_name FPSCamera extends Camera3D

func _ready() -> void:
	get_tree().current_scene.get_node("Pauser").on_unpause.connect(clear_shake);

var mouse_move_intent : Vector2;
var mouse_move_intent_intensity : float = 0;
@onready var hand_target : Node3D = $hand/Target;
@onready var hand_trigger : ShapeCast3D = $hand/Root/Skeleton3D/HandEnd/ShapeCast3D;
@onready var hand_mat : StandardMaterial3D = $hand/Root/Skeleton3D/Cube.material_override;
@onready var hand_particles : GPUParticles3D = $hand/Root/Skeleton3D/HandEnd/GPUParticles3D;

@onready var player : Player = get_parent();

@onready var base_pos : Vector3 = position;

@onready var ui : UIManager = get_tree().current_scene.get_node("CanvasLayer");

@onready var charge : AudioStreamPlayer3D = $hand/Root/Skeleton3D/HandEnd/Charge;

var shooting : bool = false;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_move_intent += event.relative;
		mouse_move_intent_intensity += event.relative.length();
	
	if event.is_action("shoot"):
		shooting = event.get_action_strength("shoot") > 0.5;

func _process(delta: float) -> void:
	if ui.paused:
		return;
	calc_shake();
	
	get_input(delta);

var shoot_move_intent : Vector3 = Vector3.ZERO;

func slap_thing(thing, hit_from):
	if thing.slappable.just_slapped:
		return;
	
	if thing.slappable.combo_mult >= 1:
		ui.inc_combo(thing.slappable.combo_mult);
		curr_shake += 0.4;
		hand_particles.emitting = true;
	else:
		curr_shake += 0.2;
	thing.slap(hit_from, mouse_move_intent_intensity/1.2, true);
	thing.slappable.player_slapped = true;

func get_input(delta : float):
	var rot : Vector2 = mouse_move_intent * delta/10;
	
	if shooting:
		hand_target.position += Vector3(rot.x, -rot.y, 0);
		
		hand_target.position = hand_target.position.clamp(Vector3(-3.8, -1, hand_target.position.z), Vector3(2.5, 2, hand_target.position.z));
		
		if hand_target.position.x < -2.8:
			shoot_move_intent.y += delta;
		elif hand_target.position.x > 1.5:
			shoot_move_intent.y -= delta;
		
		hand_particles.amount_ratio = min(mouse_move_intent_intensity/700, 1);
		
		if mouse_move_intent_intensity > 250:
			var dir = Vector3(-mouse_move_intent.x, mouse_move_intent.y, 0).normalized();
			var hit_from = global_position + global_basis * dir;
			
			for i in hand_trigger.get_collision_count():
				var c = hand_trigger.get_collider(i);
				if (c is SlappableObj or c is Enemy):
					slap_thing(c, hit_from);
				elif c.get("collision_layer") == 0b10:
					slap_thing(c.get_parent(), hit_from);
					
			hand_mat.albedo_color = lerp(hand_mat.albedo_color, Color.RED, min(delta * mouse_move_intent_intensity/50, 1.0));
			
			if mouse_move_intent_intensity > 500 and !charge.playing:
				charge.play();
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
	curr_shake *= 0.8;
	hand_particles.emitting = false;

func calc_shake():
	var shake = pow(curr_shake, 2);
	rotation.z = (PI/4) * shake * randf_range(-1, 1);
	position.x = base_pos.x + shake * randf_range(-1, 1);
	position.y = base_pos.y + shake * randf_range(-1, 1);
	curr_shake *= 0.95;
