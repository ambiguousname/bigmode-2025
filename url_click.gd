extends RichTextLabel

func _ready() -> void:
	self.meta_clicked.connect(on_click);
	
func on_click(meta):
	OS.shell_open(str(meta));
