extends Node

@onready var timer : Timer = $Timer;

func _ready() -> void:
	timer.timeout.connect(unpause);

func pause():
	await get_tree().process_frame;
	
	if timer.time_left <= 0:
		timer.start(0.1);
		get_tree().paused = true;

func unpause():
	get_tree().paused = false;
