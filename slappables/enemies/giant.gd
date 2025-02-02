extends Enemy

@onready var ui : UIManager = get_tree().current_scene.get_node("CanvasLayer");

func _ready() -> void:
	super();
	$EndGameTimer.timeout.connect(func():
		ui.win_game();
	);

func slap_behavior():
	$EndGameTimer.start();
	
