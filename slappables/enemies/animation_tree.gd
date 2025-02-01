@tool
extends AnimationTree

func _ready() -> void:
	if anim_player == null:
		anim_player = ^"../enemy/AnimationPlayer";
