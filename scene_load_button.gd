extends Button

@export var scene_to_load : String;

func _ready() -> void:
	pressed.connect(clicked);

func clicked():
	get_tree().change_scene_to_file(scene_to_load);
