class_name SpawnTrigger extends Area3D

@export var to_spawn : Array[Enemy];

func _ready() -> void:
	body_entered.connect(_body_entered);

func _body_entered(b : PhysicsBody3D):
	if b is Player:
		for e in to_spawn:
			e.spawn();
		CheckpointManager.add_to_free(self);
		body_entered.disconnect(_body_entered);

func free_stuff():
	for e in to_spawn:
		e.queue_free();
	self.queue_free();
