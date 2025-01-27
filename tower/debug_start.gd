extends Node3D

@export var debug : bool = false;

func _ready() -> void:
	if OS.has_feature("editor") and debug:
		get_tree().current_scene.get_node("Player").global_position = global_position;
		
		get_tree().current_scene.get_node("Player").global_rotation = global_rotation;
