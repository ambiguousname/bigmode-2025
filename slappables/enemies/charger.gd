class_name Charger extends Enemy

@onready var shapecast : ShapeCast3D = $ShapeCast3D;

@onready var timer : Timer = $StandTimer;

enum States {
	IDLE,
	SEARCHING,
	STAND_AND_PLAY_ANIM,
	ATTACKING,
	MOVE_BACK
};

func _ready() -> void:
	super();
	
	timer.timeout.connect(stand_done);

var active_state : States = States.IDLE;

var charge_dir : Vector3 = Vector3.ZERO;
var charge_travelled : float = 0;

func eval_behavior(delta: float):
	match active_state:
		States.IDLE:
			if player.global_position.distance_to(global_position) < 30:
				active_state = States.SEARCHING;
				anim_tree.set("parameters/conditions/run", true);
				
		States.SEARCHING:
			nav_agent.target_position = player.global_position;
			
			var dir = global_position.direction_to(nav_agent.get_next_path_position());
			
			velocity = dir * 4 + gravity;
			
			rotation.y = atan2(dir.x, dir.z);
			
			if nav_agent.is_target_reached():
				active_state = States.STAND_AND_PLAY_ANIM;
				next_state = States.ATTACKING;
				shapecast.enabled = true;
				
				velocity = gravity;
				
				timer.start(0.5);
				anim_tree.set("parameters/conditions/run", false);
				anim_tree.set("parameters/conditions/charge_windup", true);
				previous_cond = "parameters/conditions/charge_windup";
				next_cond = "parameters/conditions/charge";
				
				charge_dir = (player.global_position - global_position);
				charge_dir.y = 0;
				charge_dir = charge_dir.normalized();
				charge_travelled = 0;
				
				rotation.y = atan2(charge_dir.x, charge_dir.z);
		States.ATTACKING:
			charge_travelled += delta * 15;
			
			velocity = charge_dir * 15 + gravity;
			
			var colliding = shapecast.is_colliding();
				
			if charge_travelled > 15 or (charge_travelled > 2 and colliding):
				shapecast.enabled = false;
				if colliding:
					for i in shapecast.get_collision_count():
						var c = shapecast.get_collider(i);
						if c is Player:
							c.damage(20 * charge_travelled/3);
						elif c is Enemy or c is SlappableObj:
							c.slap(global_position, (charge_travelled + 1) * 100, false);
							
				active_state = States.STAND_AND_PLAY_ANIM;
				next_state = States.MOVE_BACK;
				
				timer.start(3);
				
				anim_tree.set("parameters/conditions/charge", false);
				anim_tree.set("parameters/conditions/cooldown", true);
				previous_cond = "parameters/conditions/cooldown";
				next_cond = "parameters/conditions/run";
				
				charge_travelled = 0;
				velocity = gravity;
				
		States.MOVE_BACK:
			if player.global_position.distance_to(global_position) > 10 or charge_travelled > 10:
				active_state = States.SEARCHING;
			
			var dir = (global_position - player.global_position).normalized();
			dir.y = 0;
			
			velocity = dir * 4 + gravity;
			charge_travelled += delta * 4;
			
			rotation.y = atan2(dir.x, dir.z);
		States.STAND_AND_PLAY_ANIM:
			return

var next_state : States = States.IDLE;
var previous_cond : String;
var next_cond : String;

func stand_done():
	active_state = next_state;
	anim_tree.set(previous_cond, false);
	anim_tree.set(next_cond, true);
