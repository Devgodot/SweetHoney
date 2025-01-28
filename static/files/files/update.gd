extends Panel

var link = ""

func _on_button_pressed():
	OS.shell_open(link)
