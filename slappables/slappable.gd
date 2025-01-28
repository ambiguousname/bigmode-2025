class_name Slappable extends RigidBody3D

var flash_mat : Material = preload("res://slappables/flash.tres");

var mesh : MeshInstance3D;
@onready var slap_timer : Timer = $SlapTimer;
@onready var combo_timer : Timer = $ComboTimer;

var combo_mult = 1;
func _ready() -> void:
	slap_timer.timeout.connect(func():
		just_slapped = false;
	);
	
	combo_timer.timeout.connect(func():
		combo_mult = 1;
	);
	
	init();

func init():
	mesh = $MeshInstance3D;

var just_slapped = false;

func flash(on : bool) -> void:
	if on:
		mesh.material_override = flash_mat;
	else:
		mesh.material_override = null;

func slap(pos, intensity):
	just_slapped = true;
	combo_mult = 0;
	
	flash(true);
	var pauser : Pauser = get_tree().current_scene.get_node("Pauser");
	pauser.on_unpause.connect(func():
		slap_timer.start();
		combo_timer.start();
		flash(false), CONNECT_ONE_SHOT);
	pauser.pause();
	
	var to = global_position - pos;
	to.y = 0;
	self.apply_impulse(to.normalized() * intensity, pos - global_position);
