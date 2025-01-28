extends Control
var save_path = "user://data.cfg"
func save(_name, num):
	var confige = ConfigFile.new()
	confige.load(save_path)
	confige.set_value("user", _name, num)
	confige.save(save_path)
func load_game(_name, defaulte = null):
	var confige = ConfigFile.new()
	confige.load(save_path)
	return confige.get_value("user", _name, defaulte)

func _on_button_pressed(mode):
	save("part_league", mode)
	Exit.change_scene("res://scenes/league_levels.tscn", true, 1)


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and not get_tree().has_group("levels"):
		_on_button_6_pressed()
func _on_button_6_pressed():
	Exit.change_scene("res://scenes/league_menu.tscn", true, 1)
