class_name UIManager extends CanvasLayer

@onready var combo_panel : Control = $ComboPanel;
@onready var progress : ProgressBar = combo_panel.get_node("ProgressBar");
@onready var combo_timer : Timer = combo_panel.get_node("ComboTimer");
@onready var combo_start : Vector2 = combo_panel.position;
@onready var combo_times : Label = combo_panel.get_node("Times");

@onready var pause_menu : Panel = $PauseMenu;

func _ready() -> void:
	combo_timer.timeout.connect(hide_combo);

var combo_count : int = 0;

func inc_combo():
	combo_count += 1;
	combo_times.text = "x%d" % combo_count;
	
	if combo_count == 1:
		combo_panel.position.y = 0;
		combo_timer.start();
	else:
		combo_timer.start(combo_timer.wait_time);

func hide_combo():
	combo_count = 0;
	combo_timer.stop();
	combo_panel.position = combo_start;

var paused : bool = false;

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		paused = !paused;
		pause(paused);

func pause(should_pause : bool):
	pause_menu.visible = should_pause;
	get_tree().paused = should_pause;

func _process(delta : float):
	progress.value = 100 * combo_timer.time_left/combo_timer.wait_time;
	
