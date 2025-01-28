class_name SlappableArea extends Area3D

@onready var slappable : Slappable = $SlappableManager;

var area_slap : Callable;

func init(mesh, on_area_slap) -> void:
	slappable.init(mesh);
	area_slap = on_area_slap;

func slap(pos, intensity):
	slappable.pre_slap();
	
	$CollisionShape3D.disabled = true;
	
	area_slap.call(pos, intensity);
