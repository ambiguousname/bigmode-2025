extends Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var mouse_move_intent : Vector2;
@onready var hand_target : Node3D = $hand/Target;
@onready var hand_trigger : Area3D = $hand/Root/Skeleton3D/HandEnd/HandEndTrigger;

@onready var player : Player = get_parent();

var shooting : bool = false;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_move_intent += event.relative;
	
	if event.is_action("shoot"):
		shooting = event.get_action_strength("shoot") > 0.5;

func _process(delta: float) -> void:
	var rot : Vector2 = mouse_move_intent * delta/10;
	
	if shooting:
		hand_target.position += Vector3(rot.x, -rot.y, 0);
		hand_target.position = hand_target.position.clamp(Vector3(-3, -0.5, hand_target.position.z), Vector3(3, 2, hand_target.position.z));
		
		if mouse_move_intent.length() > 200:
			for b in hand_trigger.get_overlapping_areas():
				if b is Enemy:
					b.ragdoll(hand_trigger.global_position);
	else:
	
		rotation.x -= rot.y;
		rotation.x = clampf(rotation.x, -PI/2 + 0.01, PI/2 - 0.01);
		
		player.rotation.y -= rot.x;
	
	mouse_move_intent *= 0.2;
