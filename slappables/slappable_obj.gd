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
	elif body is Enemy:
		if (angular_velocity.length() + linear_velocity.length()) > 20 and !body.slapped:
			body.slap(global_position, angular_velocity.length() + linear_velocity.length(), slappable.player_slapped);

func slap(pos, intensity, flash):
	slappable.pre_slap(flash);
	gravity_scale = 1;
	
	var to = global_position - pos;
	to.y = 0;
	self.apply_impulse(to.normalized() * intensity, pos - global_position);
