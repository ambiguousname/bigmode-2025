class_name Telekinetic extends Enemy

@onready var timer : Timer = $Timer;

func _ready() -> void:
	super();
	timer.timeout.connect(set_idle);

func set_idle():
	if active_state == States.SLAPPED:
		return;
	active_state = States.IDLE;

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
	for o in objs_grabbed:
		o.gravity_scale = 1;

@onready var shapecast : ShapeCast3D = $ShapeCast3D;

var objs_grabbed : Array[PhysicsBody3D];

var grav_scale : float = -1.0;

func eval_behavior(delta : float):
	match active_state:
		States.IDLE:
			if player.global_position.distance_to(global_position) < 30:
				active_state = States.SEARCHING;
				anim_tree.set("parameters/conditions/idle", false);
				anim_tree.set("parameters/conditions/run", true);
			return;
		States.SEARCHING:
			nav_agent.target_position = player.global_position;
			
			var dir = global_position.direction_to(nav_agent.get_next_path_position());
			
			velocity = dir * 4;
			
			rotation.y = atan2(dir.x, dir.z);
			
			if nav_agent.is_target_reached():
				active_state = States.ATTACKING;
				
				grav_scale = -1;
				
				shapecast.enabled = true;
				shapecast.force_shapecast_update();
				for i in shapecast.get_collision_count():
					var c = shapecast.get_collider(i);
					# TODO: Bones.
					if c is SlappableObj:
						objs_grabbed.push_back(c);
						c.gravity_scale = grav_scale;
						c.apply_impulse(Vector3.ZERO);
				
				velocity = Vector3.ZERO;
				
				shapecast.enabled = false;
				
				if objs_grabbed.size() == 0:
					active_state = States.SEARCHING;
				else:
					anim_tree.set("parameters/conditions/run", false);
					anim_tree.set("parameters/conditions/jump", true);
		States.ATTACKING:
			var l = objs_grabbed.size();
			var i = 0;
			while i < l:
				var o = objs_grabbed[i];
				if o.is_queued_for_deletion() or o.slappable.just_slapped:
					objs_grabbed.remove_at(i);
					i -= 1;
					l -= 1;
					continue;
				
				o.gravity_scale = grav_scale;
				
				i += 1;
			
			grav_scale *= 0.92;
			
			if abs(grav_scale) <= 0.001:
				anim_tree.set("parameters/conditions/jump", false);
				anim_tree.set("parameters/conditions/idle", true);
				
				grav_scale = 1;
				for o in objs_grabbed:
					o.gravity_scale = grav_scale;
					
					var dir = player.global_position - o.global_position;
					o.apply_impulse(dir.normalized() * 1000);
				objs_grabbed.clear();
				active_state = States.COOLDOWN;
				timer.start();
		States.COOLDOWN:
			return;
		States.SLAPPED:
			return;
