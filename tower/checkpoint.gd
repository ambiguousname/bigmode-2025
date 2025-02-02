class_name Checkpoint extends Area3D

func _ready() -> void:
	self.body_entered.connect(_body_entered);

func _body_entered(b : PhysicsBody3D):
	if b is Player:
		CheckpointManager.set_pos(global_position, global_rotation);
