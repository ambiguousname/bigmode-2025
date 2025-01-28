class_name UIManager extends CanvasLayer

@onready var combo_panel : Control = $ComboPanel;
@onready var progress : ProgressBar = combo_panel.get_node("ProgressBar");
@onready var combo_timer : Timer = combo_panel.get_node("ComboTimer");
@onready var combo_start : Vector2 = combo_panel.position;
@onready var combo_times : Label = combo_panel.get_node("Times");

@onready var health : ProgressBar = $Health;

@onready var pause_menu : Panel = $PauseMenu;

@onready var death_menu : Panel = $Death;

func _ready() -> void:
	combo_timer.timeout.connect(hide_combo);
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	
	pause_menu.get_node("Button").pressed.connect(pause.bind(false));
	pause_menu.get_node("Button2").pressed.connect(quit_to_menu);
	death_menu.get_node("Button").pressed.connect(func():
		get_tree().reload_current_scene();
	);
	
	death_menu.get_node("Button2").pressed.connect(quit_to_menu);

func quit_to_menu():
	get_tree().paused = false;
	get_tree().change_scene_to_file("res://main_menu.tscn");
	

var combo_count : int = 0;

func inc_combo(amnt):
	if amnt == 0:
		return;
	
	if combo_count == 0:
		combo_panel.position.y = 0;
		combo_timer.start();
	else:
		combo_timer.start(combo_timer.wait_time);
	
	combo_count += amnt;
	
	combo_times.text = "x%d" % combo_count;

func hide_combo():
	combo_count = 0;
	combo_timer.stop();
	combo_panel.position = combo_start;

var paused : bool = false;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause(!paused);

func pause(should_pause : bool):
	paused = should_pause;
	
	if should_pause:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	pause_menu.visible = should_pause;
	get_tree().paused = should_pause;

func set_health(hp):
	health.value = hp;

func die():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	death_menu.visible = true;
	get_tree().paused = true;

func _process(delta : float):
	progress.value = 100 * combo_timer.time_left/combo_timer.wait_time;
	
