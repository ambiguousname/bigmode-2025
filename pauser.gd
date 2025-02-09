class_name Pauser extends Node

@onready var timer : Timer = $Timer;

signal on_unpause();

func _ready() -> void:
	timer.timeout.connect(unpause);

func pause(time=0.1):
	await get_tree().process_frame;
	
	if timer.time_left <= 0:
		timer.start(time);
		get_tree().paused = true;

func unpause():
	get_tree().paused = false;
	on_unpause.emit();
