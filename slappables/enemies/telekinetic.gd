class_name Telekinetic extends Enemy

@onready var timer : Timer = $Timer;

func _ready() -> void:
	super();
	timer.timeout.connect(set_idle);

func set_idle():
	active_state = States.SEARCHING;
	anim_tree.set("parameters/conditions/cooldown", false);
	anim_tree.set("parameters/conditions/run", true);
	
	find_objs();
	curr_target = minimize_dist();

enum States {
	IDLE,
	SEARCHING,
	ATTACKING,
	COOLDOWN
};

var active_state : States = States.IDLE;

func slap_behavior():
	for o in objs_grabbed:
		o.gravity_scale = 1;

@onready var shapecast : ShapeCast3D = $ShapeCast3D;
@onready var search_cast : ShapeCast3D = $SearchCast;

var objs_grabbed : Array[PhysicsBody3D];
var bones_grabbed : Array[PhysicalBone3D];

var grav_scale : float = -1.0;

var targets : Array[PhysicsBody3D];

func find_objs():
	targets.clear();
	
	search_cast.enabled = true;
	
	search_cast.force_shapecast_update();
	for i in shapecast.get_collision_count():
		var c = shapecast.get_collider(i);
		if c is SlappableObj or (c.get("collision_layer") == 2 and c.get_parent().active):
			targets.push_back(c);
	search_cast.enabled = false;

func minimize_dist() -> PhysicsBody3D:
	var min_t : PhysicsBody3D = null;
	var min : float = 1000.0;
	for t in targets:
		var dist = t.global_position.distance_to(player.global_position);
		if dist < min:
			min = dist;
			min_t = t;
	return min_t;

var curr_target : PhysicsBody3D;

func eval_behavior(delta : float):
	match active_state:
		States.IDLE:
			if player.global_position.distance_to(global_position) < 30:
				find_objs();
				curr_target = minimize_dist();
				if curr_target == null:
					curr_target = player;
				active_state = States.SEARCHING;
				anim_tree.set("parameters/conditions/idle", false);
				anim_tree.set("parameters/conditions/run", true);
			return;
		States.SEARCHING:
			nav_agent.target_position = curr_target.global_position;
			
			var dir = global_position.direction_to(nav_agent.get_next_path_position());
			
			velocity = dir * 4 + gravity;
			
			rotation.y = atan2(dir.x, dir.z);
			
			if nav_agent.is_target_reached():
				active_state = States.ATTACKING;
				
				grav_scale = -1;
				
				shapecast.enabled = true;
				shapecast.force_shapecast_update();
				for i in shapecast.get_collision_count():
					var c = shapecast.get_collider(i);
					if c is SlappableObj or (c.get("collision_layer") == 2 and c.get_parent().active):
						objs_grabbed.push_back(c);
						c.gravity_scale = grav_scale;
						c.apply_impulse(Vector3.ZERO);
						
				
				velocity = gravity;
				
				shapecast.enabled = false;
				
				if objs_grabbed.size() == 0:
					active_state = States.SEARCHING;
				else:
					anim_tree.set("parameters/conditions/run", false);
					anim_tree.set("parameters/conditions/telekinesis", true);
		States.ATTACKING:
			var l = objs_grabbed.size();
			var i = 0;
			while i < l and l != 0:
				var o = objs_grabbed[i];
				var slappable = o.get("slappable");
				if slappable == null:
					slappable = o.get_parent().slappable;
				if o.is_queued_for_deletion() or slappable.just_slapped:
					objs_grabbed.remove_at(i);
					i -= 1;
					l -= 1;
					continue;
				
				o.gravity_scale = randf() * grav_scale;
				
				i += 1;
			
			grav_scale *= 0.92;
			
			if abs(grav_scale) <= 0.001:
				anim_tree.set("parameters/conditions/telekinesis", false);
				anim_tree.set("parameters/conditions/cooldown", true);
				
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
