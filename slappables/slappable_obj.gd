class_name SlappableObj extends RigidBody3D

@onready var slappable = $SlappableManager;

func _ready() -> void:
	slappable.init($MeshInstance3D);

func slap(pos, intensity):
	slappable.pre_slap();
	
	var to = global_position - pos;
	to.y = 0;
	self.apply_impulse(to.normalized() * intensity, pos - global_position);
	
