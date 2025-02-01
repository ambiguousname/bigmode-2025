class_name Slappable extends Node3D

var flash_mat : Material = preload("res://slappables/flash.tres");

var mesh : MeshInstance3D;
@onready var slap_timer : Timer = $SlapTimer;
@onready var combo_timer : Timer = $ComboTimer;

@onready var clap : AudioStreamPlayer3D = $Clap;
@onready var big_clap : AudioStreamPlayer3D = $BigClap;
@onready var smack : AudioStreamPlayer3D = $Smack;
@onready var pain : AudioStreamPlayer3D = $Pain;

var player_slapped : bool = false;

var combo_mult = 1;
func _ready() -> void:
	slap_timer.timeout.connect(func():
		just_slapped = false;
		player_slapped = false;
	);
	
	combo_timer.timeout.connect(func():
		combo_mult = 1;
	);
	
enum SFXType {
	Fleshy,
	Solid
};

var type : SFXType;

func init(mesh, type):
	self.type = type;
	self.mesh = mesh;

var just_slapped = false;

func flash(on : bool) -> void:
	if on:
		mesh.material_override = flash_mat;
	else:
		mesh.material_override = null;

func pre_slap(flash : bool, intensity : float):
	if !flash:
		return;
	
	just_slapped = true;
	combo_mult = 0;
	flash(true);
	
	match type :
		SFXType.Fleshy:
			if intensity > 350:
				big_clap.play();
				if intensity > 400:
					pain.play();
			else:
				clap.play();
		SFXType.Solid:
			smack.play();
	
	var pauser : Pauser = get_tree().current_scene.get_node("Pauser");
	pauser.on_unpause.connect(func():
		slap_timer.start();
		combo_timer.start();
		flash(false), CONNECT_ONE_SHOT);
	pauser.pause();
