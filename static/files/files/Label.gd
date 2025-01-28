extends Label
signal mouse_hover
signal mouse_exit

var size2 = 90

func _ready():
	label_settings.font_size = size2
	
	



func _on_mouse_exited():
	emit_signal("mouse_exit", self)


func _on_gui_input(event):
	if event is InputEventScreenDrag:
		emit_signal("mouse_hover", self)


func _on_mouse_entered():
	emit_signal("mouse_hover", self)
