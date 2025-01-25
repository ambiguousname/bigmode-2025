extends Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var mouse_move_intent : Vector2;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_move_intent += event.relative;

func _process(delta: float) -> void:
	var rot : Vector2 = mouse_move_intent * delta/10;
	mouse_move_intent *= 0.2;
	rotation.x -= rot.y;
	rotation.x = clampf(rotation.x, -PI/2 + 0.01, PI/2 - 0.01);
	
	rotation.y -= rot.x;
