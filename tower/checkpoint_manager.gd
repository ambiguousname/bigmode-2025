extends Node

var checkpoint_pos : Vector3 = Vector3.ZERO;

func set_pos(p: Vector3):
	checkpoint_pos = p;

func get_respawn_point() -> Vector3:
	return checkpoint_pos;
