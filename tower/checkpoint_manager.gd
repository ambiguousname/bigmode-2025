extends Node

var checkpoint_pos : Vector3 = Vector3.ZERO;
var checkpoint_rot : Vector3 = Vector3.ZERO;

func set_pos(p: Vector3, r : Vector3):
	checkpoint_pos = p;
	checkpoint_rot = r;

func get_respawn_point():
	return [checkpoint_pos, checkpoint_rot];

var trigger_free_stack : Array[SpawnTrigger];

func add_to_free(trigger : SpawnTrigger):
	trigger_free_stack.push_front(trigger);
	if trigger_free_stack.size() > 2:
		var s : SpawnTrigger = trigger_free_stack.pop_back();
		s.free_stuff();
