class_name Enemy extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D;

@onready var player : Player = get_tree().current_scene.get_node("Player");

@onready var bones : PhysicalBoneSimulator3D = $Skeleton3D/PhysicalBoneSimulator3D;

func _ready() -> void:
	$Area3D.init($Skeleton3D/Robot, func(pos, intensity):
		$CollisionShape3D.disabled = true;
		
		bones.active = true;
		bones.physical_bones_start_simulation();
		var bone : PhysicalBone3D = bones.get_node("Physical Bone hip");
		
		var to = global_position - pos;
		to.y = 0;
		bone.apply_impulse(to.normalized() * intensity, pos - global_position);
	);

enum States {
	IDLE,
	SEARCHING,
	ATTACKING
};

var active_state : States = States.IDLE;

func _physics_process(delta: float) -> void:
	match active_state:
		States.IDLE:
			if player.global_position.distance_to(global_position) < 40:
				active_state = States.SEARCHING;
		States.SEARCHING:
			if nav_agent.is_target_reached():
				active_state = States.ATTACKING;
			
			nav_agent.target_position = player.global_position;
			
			velocity = global_position.direction_to(nav_agent.get_next_path_position()) * 4;
		States.ATTACKING:
			if player.global_position.distance_to(global_position) > 5:
				active_state = States.IDLE;
			velocity = Vector3.ZERO;
	
	move_and_slide();
