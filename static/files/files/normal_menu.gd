extends Control

var level = 1
var max_level = 1
var unlock_level = 1
var save_path = "user://data.cfg"
var part = 0
var teach = true
# Called when the node enters the scene tree for the first time.
func save(_name, num):
	var confige = ConfigFile.new()
	confige.load(save_path)
	confige.set_value("user", _name, num)
	confige.save(save_path)
func load_game(_name, defaulte=null):
	var confige = ConfigFile.new()
	confige.load(save_path)
	return confige.get_value("user", _name, defaulte)
func load_game2(_name, defaulte=null):
	var confige = ConfigFile.new()
	confige.load("user://files.cfg")
	return confige.get_value("user", _name, defaulte)
func _ready():
	if FileAccess.file_exists(save_path):
		level = load_game("level", 1)
		teach = load_game("teach", true)
		$VBoxContainer/HBoxContainer4/Control/Panel/Label.text = load_game('name', "")
		$VBoxContainer/HBoxContainer4/Control/Panel/Label.editable = false
		part = load_game("part", 0)
	
	match part:
		0:
			max_level = await UpdateData.get_max_level("کاوش در منطقه", "mosque")
			unlock_level = await UpdateData.get_data("um", 1)
		1:
			max_level = await UpdateData.get_max_level("کاوش در منطقه", "home")
			unlock_level = await UpdateData.get_data("uh", 1)
		2:
			max_level = await UpdateData.get_max_level("کاوش در منطقه", "school")
			unlock_level = await UpdateData.get_data("us", 1)
		3:
			max_level = await UpdateData.get_max_level("کاوش در منطقه", "village")
			unlock_level = await UpdateData.get_data("uv", 1)
		4:
			max_level = await UpdateData.get_max_level("کاوش در منطقه", "VE")
			unlock_level = await UpdateData.get_data("uve", 1)
	if level > max_level:
		level = max_level
		UpdateData.save("level", level)
	if load_game("icon", "") != "":
		$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/Label.hide()
		var tex = load("res://sprite/user_img.png")
		var image = Image.new()
		image.load("user://icons/"+load_game("icon"))
		tex = ImageTexture.create_from_image(image)
		$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/TextureRect2.texture_normal = tex
	else:
		$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/TextureRect2.texture_normal = load("res://sprite/user_img.png")
	$VBoxContainer/HBoxContainer4/Control/Panel/Label2.text = "امتیاز : "+ str(load_game("score", 0))
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect2.value = load_game("score", 0) * 100 / 5000
func _process(delta):
	modulate = [Color.WHITE, Color("4f4f4f")][int($icons.visible)]

	
func _on_texture_button_pressed():
	$icons.show()
	
	

func _on_label_text_submitted(new_text):
	var t = new_text.split(" ")
	var text = ""
	for x in t:
		if x != "":
			text += x
	if text != "" and new_text != "":
		UpdateData.save("name", new_text)
		$VBoxContainer/HBoxContainer4/Control/Panel/Label.editable = false

func _on_edit_name_pressed():
	$VBoxContainer/HBoxContainer4/Control/Panel/Label.editable = true


func _on_icons_button_pressed(img):
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/TextureRect2.texture_normal = img
	$icons.hide()
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/Label.hide()


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and not get_tree().has_group("menu_levels"):
		_on_persian_button_3_pressed()
func _on_levels_pressed():
	var m = preload("res://scenes/menu_levels.tscn").instantiate()
	m.teach = teach
	hide()
	m.p_scene = self
	get_tree().get_root().add_child(m)
	


func _on_persian_button_pressed():
	level = load_game("level_data")[0]
	part = load_game("level_data")[1]
	UpdateData.multy_save({"level":level, "part": part})
	Exit.change_scene("res://scenes/main.tscn")

func _on_persian_button_3_pressed():
	Exit.change_scene("res://scenes/start.tscn")
	
func _on_gui_input(event):
	if event is InputEventScreenTouch:
		var t = $VBoxContainer/HBoxContainer4/Control/Panel/Label.text.split(" ")
		var text = ""
		for x in t:
			if x != "":
				text += x
		if text != "" and $VBoxContainer/HBoxContainer4/Control/Panel/Label.text != "":
			UpdateData.save("name", $VBoxContainer/HBoxContainer4/Control/Panel/Label.text)
			$VBoxContainer/HBoxContainer4/Control/Panel/Label.editable = false


func _on_label_gui_input(event):
	if event.is_pressed():
		$VBoxContainer/HBoxContainer4/Control/Panel/Label.editable = true
