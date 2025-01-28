extends Control

var level = 1
var max_level = 1
var score = 0
var part = 0
var end_level = false
var save_path = "user://data.cfg"
func write_num(_name, num):
	var file = FileAccess.open("user://files/"+_name+".txt", FileAccess.WRITE)
	file.store_var(num)
	file.close()
func save(_name, num):
	var confige = ConfigFile.new()
	confige.load(save_path)
	confige.set_value("user", _name, num)
	confige.save(save_path)
func load_game(_name, defaulte=null):
	var confige = ConfigFile.new()
	confige.load(save_path)
	return confige.get_value("user", _name, defaulte)
func _ready():
	randomize()
	if score != 0:
		$VBoxContainer/Label.text = "امتیاز گرفته شده : "+ str(score)
	else:
		$VBoxContainer/Label.text = ""
	level = load_game("level")
	part = int(load_game("part", 0))
	match part:
		0:
			max_level = await UpdateData.get_max_level("کاوش در منطقه", "mosque")
		1:
			max_level = await UpdateData.get_max_level("کاوش در منطقه", "home")
		2:
			max_level = await UpdateData.get_max_level("کاوش در منطقه", "school")
		3:
			max_level = await UpdateData.get_max_level("کاوش در منطقه", "village")
		4:
			max_level = await UpdateData.get_max_level("کاوش در منطقه", "VE")
	if level + 1 > max_level:
		$VBoxContainer/HBoxContainer/GridContainer/PersianButton3.hide()
		if part < load_game("max_part", 5) - 1:
			$VBoxContainer/HBoxContainer/GridContainer/PersianButton5.show()
		else:
			$lights.show()
			$VBoxContainer/HBoxContainer/GridContainer/Label.show()
			end_level = true
			$AnimationPlayer.play("end_level")
func _on_PersianButton4_pressed():
	Exit.change_scene("res://scenes/main.tscn")
	
func _process(delta):
	if end_level:
		if randi_range(0, 20) == 1:
			for light in $lights.get_children():
				var tween = get_tree().create_tween()
				tween.tween_property(light, "position", Vector2(randi_range(0, 768), randi_range(0, 1366)), randf_range(1, 1.5))
		
		if randi_range(0, 20) == 1:
			var e = preload("res://scenes/EXPLOSION.tscn").instantiate()
			add_child(e)


func _on_PersianButton3_pressed():
	UpdateData.save("level", level + 1)
	Exit.change_scene("res://scenes/main.tscn")
	


func _on_PersianButton_pressed():
	get_tree().quit()


func _on_PersianButton2_pressed():
	var m = preload("res://scenes/menu_levels.tscn").instantiate()
	m.p_scene = self
	hide()
	get_tree().get_root().add_child(m)




func _on_PersianButton5_pressed():
	part += 1
	UpdateData.multy_save({"part":part, "level":1})
	Exit.change_scene("res://scenes/main.tscn")


func _on_persian_button_8_pressed():
	
	Exit.change_scene("res://scenes/start.tscn")
