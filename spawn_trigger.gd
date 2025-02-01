extends Area3D

@export var to_spawn : Array[Enemy];

func _ready() -> void:
	body_entered.connect(_body_entered);
	
func _body_entered(b : PhysicsBody3D):
	if b is Player:
		for e in to_spawn:
			e.spawn();
		self.queue_free();
