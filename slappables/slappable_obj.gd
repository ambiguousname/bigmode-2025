class_name SlappableObj extends RigidBody3D

@onready var slappable = $SlappableManager;

func _ready() -> void:
	slappable.init($MeshInstance3D, Slappable.SFXType.Solid);
	
	self.contact_monitor = true;
	self.max_contacts_reported = 1;
	self.body_entered.connect(body_hit);
	
func body_hit(body : PhysicsBody3D):
	if body is Player:
		body.damage(clamp(linear_velocity.length(), 1, 50));
	elif body is Enemy:
		if (angular_velocity.length() + linear_velocity.length()) > 15 and !body.slapped:
			body.slap(global_position, angular_velocity.length() + linear_velocity.length(), slappable.player_slapped);

func slap(pos, intensity, flash):
	slappable.pre_slap(flash, intensity);
	gravity_scale = 1;
	
	var to = global_position - pos;
	to.y = 0;
	self.apply_impulse(to.normalized() * intensity, pos - global_position);
