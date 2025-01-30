class_name Charger extends Enemy

@onready var shapecast : ShapeCast3D = $ShapeCast3D;

enum States {
	IDLE,
	SEARCHING,
	ATTACKING,
	COOLDOWN,
	SLAPPED
};

var active_state : States = States.IDLE;

func slap_behavior():
	active_state = States.SLAPPED;

var charge_dir : Vector3 = Vector3.ZERO;
var charge_travelled : float = 0;

func eval_behavior(delta: float):
	match active_state:
		States.IDLE:
			if player.global_position.distance_to(global_position) < 30:
				active_state = States.SEARCHING;
				anim_tree.set("parameters/conditions/run", true);
				
		States.SEARCHING:
			if nav_agent.is_target_reached():
				active_state = States.ATTACKING;
				anim_tree.set("parameters/conditions/run", false);
				anim_tree.set("parameters/conditions/shoot", true);
				
				charge_dir = (player.global_position - global_position).normalized();
				charge_travelled = 0;
				
				rotation.y = atan2(charge_dir.x, charge_dir.z);
			
			nav_agent.target_position = player.global_position;
			
			var dir = global_position.direction_to(nav_agent.get_next_path_position());
			
			velocity = dir * 4;
			
			rotation.y = atan2(dir.x, dir.z);
		States.ATTACKING:
			charge_travelled += delta * 4;
			
			velocity = charge_dir * 10;
			
			var colliding = shapecast.is_colliding();
				
			if charge_travelled > 10 or colliding:
				active_state = States.COOLDOWN;
				anim_tree.set("parameters/conditions/shoot", false);
				velocity = Vector3.ZERO;
				
				if colliding:
					for i in shapecast.get_collision_count():
						var c = shapecast.get_collider(i);
						if c is Player:
							c.damage(20);
						elif c is Enemy or c is SlappableObj:
							c.slap(global_position, (charge_travelled + 1) * 1000);
		States.SLAPPED:
			return;
