extends PopupPanel



func _on_button_2_pressed():
	hide()

func _on_button_pressed():
	Exit.change_scene("res://scenes/intro.tscn", false)
