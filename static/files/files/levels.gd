extends Control
enum Mode{mosque,  Home, school, Village, VE}
var mode = Mode.Home
var max_level = 1
var unlock_level = 1
var save_path = "user://data.cfg"
var col = 5
var rot_hand = true
var rot_hand2 = true
var pages = [15, 20, 25, 30, 35]
func save(_name, num):
	var confige = ConfigFile.new()
	confige.load(save_path)
	confige.set_value("user", _name, num)
	confige.save(save_path)
func load_game(_name, defaulte=null):
	var confige = ConfigFile.new()
	confige.load(save_path)
	return confige.get_value("user", _name, defaulte)
func _process(delta: float) -> void:
	if $Node2D3.visible:
		if randi_range(1, 200) == 1 and rot_hand:
			rot_hand= false
			var tween = get_tree().create_tween()
			tween.tween_property($Node2D3/Node2D, "position:x", randi_range(786, 936), randf_range(0.2, 0.5))
			tween.play()
			await tween.finished
			rot_hand = true
		if randi_range(1, 200) == 1 and rot_hand2:
			rot_hand2 = false
			var tween = get_tree().create_tween()
			tween.tween_property($Node2D3/Node2D2, "position:y", randi_range(1528, 1673), randf_range(0.2, 0.5))
			tween.play()
			await tween.finished
			rot_hand2 = true
		
func _ready():
	match mode:
		Mode.Home:
			$TextureRect.texture = preload("res://sprite/Untitled-1.jpg")
			max_level = await UpdateData.get_max_level("کاوش در منطقه", "home")
			unlock_level = await UpdateData.get_data("uh", 1)
			$ScrollContainer/GridContainer.add_theme_constant_override("h_separation", 110)
			$ScrollContainer2/VBoxContainer.add_theme_constant_override("separation", 110)
			$ScrollContainer/GridContainer.add_theme_constant_override("v_separation", 110)
			$AnimationPlayer2.play("home")
		Mode.Village:
			$TextureRect.texture = preload("res://sprite/mahale5.jpg")
			max_level = await UpdateData.get_max_level("کاوش در منطقه", "village")
			unlock_level = await UpdateData.get_data("uv", 1)
			$ScrollContainer2/VBoxContainer.add_theme_constant_override("separation", 110)
			$ScrollContainer/GridContainer.add_theme_constant_override("v_separation", 110)
			$ScrollContainer/GridContainer.add_theme_constant_override("h_separation", 120)
			$AnimationPlayer2.play("village")
		Mode.school:
			col = 7
			$AnimationPlayer2.play("school")
			max_level = await UpdateData.get_max_level("کاوش در منطقه", "school")
			unlock_level = await UpdateData.get_data("us", 1)
			$TextureRect.texture = preload("res://sprite/madrase2.jpg")
			$ScrollContainer/GridContainer.columns = col
			$ScrollContainer2/VBoxContainer.add_theme_constant_override("separation", 140)
			$ScrollContainer/GridContainer.add_theme_constant_override("v_separation", 140)
			$ScrollContainer/GridContainer.add_theme_constant_override("h_separation", 100)
		Mode.mosque:
			col = 5
			$ScrollContainer2/VBoxContainer.add_theme_constant_override("separation", 110)
			max_level = await UpdateData.get_max_level("کاوش در منطقه", "mosque")
			$ScrollContainer/GridContainer.columns = col
			unlock_level = await UpdateData.get_data("um", 1)
			$TextureRect.texture = preload("res://sprite/masjed9.jpg")
			$ScrollContainer/GridContainer.add_theme_constant_override("v_separation", 160)
			$ScrollContainer/GridContainer.add_theme_constant_override("h_separation", 160)
			$AnimationPlayer2.play("mosque")
		Mode.VE:
			col = 6
			$ScrollContainer2/VBoxContainer.add_theme_constant_override("separation", 110)
			max_level = await UpdateData.get_max_level("کاوش در منطقه", "VE")
			$ScrollContainer/GridContainer.columns = col
			unlock_level = await UpdateData.get_data("uve", 1)
			$TextureRect.texture = preload("res://sprite/فضای مجازی4.png")
			$ScrollContainer/GridContainer.add_theme_constant_override("v_separation", 160)
			$ScrollContainer/GridContainer.add_theme_constant_override("h_separation", 160)
			$AnimationPlayer2.play("VE")
	$ScrollContainer2.size = $ScrollContainer.size
	$ScrollContainer2.position = $ScrollContainer.position
	
	if mode != Mode.Home:
		$Node2D.hide()
		
		var num_pages = []
		var max_page = int(max_level / pages[mode]) + 1
		for x in range(max_page):
			if x + 1 != max_page:
				num_pages.append(pages[mode])
			else :
				num_pages.append(max_level % pages[mode])
		var current_page = int((unlock_level - 1) / pages[mode])
		for x in range(num_pages[current_page]):
			add_btn(x + (current_page * pages[mode]))
	else:
		reset_btn()
	
func write_num(_name, num):
	var file = FileAccess.open("user://files/"+_name+".txt", FileAccess.WRITE)
	file.store_var(num)
	file.close()
func add_btn(lv):
	var texturs_normal = ["res://sprite/Untitled_۲۰۲۴۱۱۲۹_۱۶۰۵۰۴.png","res://sprite/honey.png","res://sprite/gol3.png", "res://sprite/iconmahale-.png", "res://sprite/ve_btn_n.png"]
	var texturs_disabled = [ "res://sprite/Untitled_۲۰۲۴۱۱۲۹_۱۶۰۵۰۴_d.png", "res://sprite/empty_honey.png", "res://sprite/gol4.png","res://sprite/iconmahale1-.png", "res://sprite/Untitled_۲۰۲۴۱۱۳۰_۰۸۱۸۵۳ (1)_d.png"]
	var texturs_pressed = ["res://sprite/Untitled_۲۰۲۴۱۱۲۹_۱۶۰۵۰۴.png", "res://sprite/honey (11).png", "res://sprite/gol5.png","res://sprite/iconmahale13-.png", "res://sprite/Untitled_۲۰۲۴۱۱۳۰_۰۸۱۸۵۳ (1).png"]

	var btn = TextureButton.new()
	btn.texture_normal = load(texturs_normal[mode])
	btn.texture_disabled = load(texturs_disabled[mode])
	btn.texture_pressed = load(texturs_pressed[mode])
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn.ignore_texture_size = true
	btn.pressed.connect(on_btn_pressed.bind(lv + 1))
	btn.size = Vector2(100, 100)
	btn.add_theme_constant_override("outline_size", 10)
	var label = Label.new()
	label.add_theme_color_override("font_color", Color.DARK_GREEN)
	label.add_theme_font_override("font", preload("res://fonts/B Titr Bold_0.ttf"))
	label.add_theme_color_override("font_outline_color", Color("ffffff"))
	label.text = str(lv + 1)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	match mode:
		0:
			btn.texture_normal = $SubViewport.get_texture()
			label.add_theme_font_size_override("font_size", 75)
			label.add_theme_constant_override("outline_size", 10)
			btn.size = Vector2(150, 150)
		1:
			label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			label.add_theme_font_size_override("font_size", 50)
			label.add_theme_constant_override("outline_size", 5)
			label.add_theme_color_override("font_outline_color", Color("ffffff"))
		2:
			btn.texture_normal = $SubViewport3.get_texture()
			btn.size = Vector2(100, 162)
			label.add_theme_constant_override("outline_size", 5)
			label.add_theme_color_override("font_outline_color", Color.BLACK)
			label.add_theme_color_override("font_color", Color.WHEAT)
			label.add_theme_font_size_override("font_size", 65)
			label.add_theme_constant_override("outline", 5)
		3:
			btn.texture_normal = $SubViewport2.get_texture()
			btn.size = Vector2(110, 110)
			label.add_theme_constant_override("outline_size", 5)
			label.add_theme_color_override("font_outline_color", Color.BLACK)
			label.add_theme_color_override("font_color", Color.RED)
			label.add_theme_font_size_override("font_size", 65)
			label.add_theme_constant_override("outline", 5)
		4:
			btn.texture_normal = $SubViewport4.get_texture()
			btn.size = Vector2(120, 120)
			label.add_theme_constant_override("outline_size", 10)
			label.add_theme_color_override("font_outline_color", Color.BLACK)
			label.add_theme_color_override("font_color", Color.WHITE)
			label.add_theme_font_size_override("font_size", 65)
	btn.add_child(label)
	if lv + 1 > unlock_level:
		btn.disabled = true
	var control = Control.new()
	control.add_child(btn)
	$ScrollContainer/GridContainer.add_child(control)
	if lv == max_level - 1:
		for x in range(max_level % col):
			$ScrollContainer/GridContainer.add_child(Control.new())
func reset_btn():
	await $AnimationPlayer.animation_finished
	var num_pages = []
	var max_page = int(max_level / pages[mode]) + 1
	for x in range(max_page):
		if x + 1 != max_page:
			num_pages.append(pages[mode])
		else :
			num_pages.append(max_level % pages[mode])
	var current_page = int((unlock_level - 1) / pages[mode])
	
	$AnimationPlayer.play("reset_btn")
	for lv in range(pages[mode]):
		var btn = $Node2D/buttons.get_child(lv)
		btn.text = str((lv + 1) + (current_page * pages[mode]))
		btn.pressed.connect(on_btn_pressed.bind(lv + 1))
		if (lv + 1) + (current_page * pages[mode]) > unlock_level:
			btn.disabled = true
		else :
			btn.disabled = false
		if lv + 1 > num_pages[current_page]:
			btn.hide()
		
func add_btn_mobile(max_lv):
	var texturs_normal = ["res://sprite/honey.png", "res://sprite/iconmahale-.png", "res://sprite/gol3.png", "res://sprite/3.png"]
	var texturs_disabled = ["res://sprite/empty_honey.png", "res://sprite/iconmahale1-.png", "res://sprite/gol4.png", "res://sprite/5.png"]
	var texturs_pressed = ["res://sprite/honey (11).png", "res://sprite/iconmahale13-.png", "res://sprite/gol5.png", "res://sprite/4.png"]
	for x in range(int(max_lv / col) + 1):
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		match mode:
			0:
				hbox.add_theme_constant_override("separation", 110)
				
			1:
				hbox.add_theme_constant_override("separation", 110)
				
			2:
				hbox.add_theme_constant_override("separation", 90)
				
			3:
				hbox.add_theme_constant_override("separation", 100)
	
		$ScrollContainer2/VBoxContainer.add_child(hbox)
	for lv in range(max_lv):
		var btn = TextureButton.new()
		btn.texture_normal = load(texturs_normal[mode])
		btn.texture_disabled = load(texturs_disabled[mode])
		btn.texture_pressed = load(texturs_pressed[mode])
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.ignore_texture_size = true
		btn.pressed.connect(on_btn_pressed.bind(lv + 1))
		btn.size = Vector2(100, 100)
		btn.add_theme_constant_override("outline_size", 10)
		var label = Label.new()
		label.add_theme_color_override("font_color", Color("1a6f4f"))
		label.add_theme_font_override("font", preload("res://fonts/B Titr Bold_0.ttf"))
		label.add_theme_color_override("font_outline_color", Color("fdfdfd"))
		label.text = str(lv + 1)
		match mode:
			0:
				label.add_theme_font_size_override("font_size", 45)
				label.add_theme_constant_override("outline", 5)
				btn.size = Vector2(100, 100)
			1:
				label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
				label.add_theme_font_size_override("font_size", 50)
				label.add_theme_constant_override("outline_size", 5)
				label.add_theme_color_override("font_outline_color", Color("ffffff"))
			2:
				btn.size = Vector2(80, 130)
				label.add_theme_constant_override("outline_size", 5)
				label.add_theme_color_override("font_outline_color", Color.BLACK)
				label.add_theme_color_override("font_color", Color.WHEAT)
				label.add_theme_font_size_override("font_size", 45)
				label.add_theme_constant_override("outline", 5)
			3:
				btn.size = Vector2(90, 90)
				label.add_theme_constant_override("outline_size", 5)
				label.add_theme_color_override("font_outline_color", Color.BLACK)
				label.add_theme_color_override("font_color", Color.RED)
				label.add_theme_font_size_override("font_size", 45)
				label.add_theme_constant_override("outline", 5)
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		btn.add_child(label)
		if lv + 1 > unlock_level:
			btn.disabled = true
		var control = Control.new()
		control.add_child(btn)
		$ScrollContainer2/VBoxContainer.get_child(int(lv / col)).add_child(control)
		
func on_btn_pressed(lv):
	var d = {}
	if load_game("level_data", [1, 0])[0] != lv or load_game("level_data", [1, 0])[1] != mode:
		
		d["answer_data"] = []
	d["level"] = lv
	d["part"] = mode
	UpdateData.multy_save(d)
	Exit.change_scene("res://scenes/main.tscn")


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_persian_button_pressed()

func _on_persian_button_pressed():
	$AnimationPlayer.play_backwards("zoom")
	await $AnimationPlayer.animation_finished
	if get_tree().has_group("menu_levels"):
		get_tree().get_nodes_in_group("menu_levels")[0].get_node("AnimationPlayer").play_backwards("zoom")
		get_tree().get_nodes_in_group("menu_levels")[0].zoom = false
		get_tree().get_nodes_in_group("menu_levels")[0].get_node("Camera2D").enabled = true
	queue_free()


func _on_animation_player_2_animation_finished(anim_name):
	$ScrollContainer2.size = $ScrollContainer.size
	$ScrollContainer2.position = $ScrollContainer.position
