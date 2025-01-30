class_name Telekinetic extends Enemy

enum States {
	IDLE,
	SEARCHING,
	ATTACKING,
	SLAPPED
};

var active_state : States = States.IDLE;

func slap_behavior():
	active_state = States.SLAPPED;

@onready var shapecast : ShapeCast3D = $ShapeCast3D;

var objs_grabbed : Array[PhysicsBody3D];

func eval_behavior(delta : float):
	match active_state:
		States.IDLE:
			if player.global_position.distance_to(global_position) < 30:
				active_state = States.SEARCHING;
				anim_tree.set("parameters/conditions/run", true);
			return;
		States.SEARCHING:
			if nav_agent.is_target_reached():
				active_state = States.ATTACKING;
				
				shapecast.enabled = true;
				for i in shapecast.get_collision_count():
					var c = shapecast.get_collider(i);
					# TODO: Bones.
					if c is SlappableObj:
						objs_grabbed.push_back(c);
						c.gravity_scale = -1;
				
				shapecast.enabled = false;
				
				anim_tree.set("parameters/conditions/run", false);
				anim_tree.set("parameters/conditions/jump", true);
			
			nav_agent.target_position = player.global_position;
			
			var dir = global_position.direction_to(nav_agent.get_next_path_position());
			
			velocity = dir * 4;
			
			rotation.y = atan2(dir.x, dir.z);
		States.ATTACKING:
			pass
		States.SLAPPED:
			return;
