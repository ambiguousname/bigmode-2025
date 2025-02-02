extends Area3D

func _ready() -> void:
	body_entered.connect(_body_entered);

func _body_entered(b : PhysicsBody3D):
	if b is Player:
		b.slam_allowed = true;
		b.velocity += Vector3.UP * 50;
