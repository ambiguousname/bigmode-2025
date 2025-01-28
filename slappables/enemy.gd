class_name Enemy extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D;

@onready var player : Player = get_tree().current_scene.get_node("Player");

@onready var bones : PhysicalBoneSimulator3D = $Skeleton/Skeleton3D/PhysicalBoneSimulator3D;

@onready var anim_tree : AnimationTree = $AnimationTree;

func _ready() -> void:
	$Area3D.init($Skeleton/Skeleton3D/Robot, func(pos, intensity):
		active_state = States.SLAPPED;
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
	ATTACKING,
	SLAPPED
};

var active_state : States = States.IDLE;

func _physics_process(delta: float) -> void:
	match active_state:
		States.IDLE:
			if player.global_position.distance_to(global_position) < 40:
				active_state = States.SEARCHING;
				anim_tree.set("parameters/conditions/run", true);
				
		States.SEARCHING:
			if nav_agent.is_target_reached():
				active_state = States.ATTACKING;
				anim_tree.set("parameters/conditions/run", false);
				anim_tree.set("parameters/conditions/shoot", true);
			
			nav_agent.target_position = player.global_position;
			
			var dir = global_position.direction_to(nav_agent.get_next_path_position());
			
			velocity = dir * 4;
			
			rotation.y = atan2(dir.x, dir.z);
		States.ATTACKING:
			var dlt = player.global_position - global_position;
			var dir = dlt.normalized();
			rotation.y = atan2(dir.x, dir.z);
			if dlt.length() > 5:
				active_state = States.IDLE;
				anim_tree.set("parameters/conditions/shoot", false);
			velocity = Vector3.ZERO;
		States.SLAPPED:
			return;
	
	move_and_slide();
