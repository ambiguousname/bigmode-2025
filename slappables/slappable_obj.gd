class_name SlappableObj extends RigidBody3D

@onready var slappable = $SlappableManager;

func _ready() -> void:
	slappable.init($MeshInstance3D);
	
	self.contact_monitor = true;
	self.max_contacts_reported = 1;
	self.body_entered.connect(body_hit);
	
func body_hit(body : PhysicsBody3D):
	if body is Player:
		body.damage(linear_velocity.length());

func slap(pos, intensity, flash):
	slappable.pre_slap(flash);
	
	var to = global_position - pos;
	to.y = 0;
	self.apply_impulse(to.normalized() * intensity, pos - global_position);
