extends Control
signal start
var target_word = []
var word
var target
var text = ""
var true_answer = false
var answered = false
var drag = true
var level = 1
var unlock_level = 1
var data = {}
var max_size = 150
var ready2 = true
var start_pos
var winer = false
var words = []
var rotate_words = false
var back_rotate_words = false
var stop_rotate_words = false
var speed_rotate = 0
var save_path = "user://data.cfg"
var w_answer_list = []
var table_box = []
var current_word = []
var current_word2
var current_word_exit = false
var current_btn
var score = 0
var part = 0
var answer_data = []
var table_word_r = []
var table_word_c = []
var menu_open = false
var max_level = 1
var ques_menu = false
func update_score(num=0):
	score = load_game("score", 0)
	score += num
	$Control/Label.text = str(score)
func find_word(box):
	box.get_child(0).emitting = true
func help(state, _score, id):
	randomize()
	var result = await UpdateData.purchase(id)
	if result:
		update_score()
		if state == 0:
			var words2 = []
			if data.state == 0:
				for x in range(data.answers.size()):
					for y in range(data.answers[x].length()):
						words2.append(Vector2(x, y))
						for a in w_answer_list:
							if x == a.x and y == a.y:
								words2.erase(Vector2(x, y))
				if words2.size() > 0:
					var z = randi_range(0, words2.size() - 1)
					var x = words2[z].x
					var y = words2[z].y
					var hbox = get_tree().get_nodes_in_group("answer"+str(x))[0]
					hbox.get_child(y).text = data.answers[x][data.answers[x].length() - 1 - y]
					find_word(hbox.get_child(y))
					w_answer_list.append(Vector2(x, y))
					answer_data[x][y] = data.answers[x][data.answers[x].length() - 1 - y]
			if data.state == 1:
				for box in table_box:
					words2.append(box)
					if get_tree().get_nodes_in_group("answer_"+str(box.x)+"_"+str(box.y))[0].text != "":
						words2.erase(box)
				if words2.size() > 0:
					var z = randi_range(0, len(words2) - 1)
					var x = words2[z].x
					var y = words2[z].y
					var box = get_tree().get_nodes_in_group("answer_"+str(x)+"_"+str(y))[0]
					box.text = data.data[x][y]
					answer_data[x][y] = data.data[x][y]
					find_word(box)
			if data.state == 5:
				var l = get_tree().get_nodes_in_group("box_answer")
				for label in get_tree().get_nodes_in_group("box_answer"):
					if label.get_children().size() > 0:
						if label.get_child(0).get_meta("static") == true:
							l.erase(label)
				var label = l[randi_range(0, l.size() - 1)]
				for button in get_tree().get_nodes_in_group("word_box"):
					if label.get_meta("txt") == button.text and button.get_meta("static") == false:
						for btn2 in get_tree().get_nodes_in_group("guess_box"):
							if btn2.get_meta("num") == button.get_meta("num"):
								btn2.queue_free()
						if label.get_children().size() > 0:
							label.get_child(0).get_meta("word").disabled = false
							label.get_child(0).get_meta("word").mouse_filter = MOUSE_FILTER_STOP
							label.get_child(0).queue_free()
						button.set_meta("static", true)
						var btn = button.duplicate()
						btn.get_child(0).emitting = true
						var style = $Label.get_theme_stylebox("normal")
						btn.add_theme_stylebox_override("normal", style)
						btn.add_theme_stylebox_override("pressed", style)
						btn.add_theme_stylebox_override("hover", style)
						button.disabled = true
						button.mouse_filter = MOUSE_FILTER_IGNORE
						btn.disabled = false
						btn.position = Vector2(0, 0)
						btn.set_meta("word", button)
						btn.add_to_group("guess_box")
						btn.remove_from_group("word_box")
						if label:
							btn.set_meta("id", label.get_meta("id"))
							label.add_child(btn)
						break
			UpdateData.save("answer_data", answer_data)
			if words2.size() == 1:
				await get_tree().create_timer(1.5).timeout
				win()
		if state == 1:
			
			var words_list = []
			var words_r_list = []
			var words_c_list = []
			if data.state == 0:
				true_answer_animation()
				for x in range(data.answers.size()):
					var hbox = get_tree().get_nodes_in_group("answer"+str(x))[0]
					words_list.append(x)
					var a = true
					for box in hbox.get_children():
						if box.text == "":
							a = false
					if a:
						words_list.erase(x)
				if words_list.size() > 0:
					var z = randi_range(0, len(words_list) - 1)
					var x = words_list[z]
					var hbox = get_tree().get_nodes_in_group("answer"+str(x))[0]
					for y in range(hbox.get_children().size()):
						hbox.get_child(y).text = data.answers[x][data.answers[x].length() - 1 - y]
						answer_data[x][y] = data.answers[x][data.answers[x].length() - 1 - y]
						find_word(hbox.get_child(y))
						w_answer_list.append(Vector2(x, y))
			if data.state == 1:
				true_answer_animation()
				for x in range(data.answers[0].size()):
					var boxs = get_tree().get_nodes_in_group("answer_r_"+str(x))
					var a = false
					words_r_list.append(x)
					for box in boxs:
						if box.text == "":
							a = true
					if !a:
						words_r_list.erase(x)
				for x in range(data.answers[1].size()):
					var boxs = get_tree().get_nodes_in_group("answer_c_"+str(x))
					words_c_list.append(x)
					var a = false
					for box in boxs:
						if box.text == "":
							a = true
					if !a:
						words_c_list.erase(x)
				if words_c_list.size() > 0 and words_r_list.size() > 0:
					var r = randi_range(0, 1)
					if r == 0:
						var z = randi_range(0, len(words_r_list) - 1)
						var x = words_r_list[z]
						var boxs = get_tree().get_nodes_in_group("answer_r_"+str(x))
						for y in range(boxs.size()):
							boxs[y].text = data.answers[0][data.answers[0].size() - x - 1][data.answers[0][data.answers[0].size() - x - 1].length() - y - 1]
							answer_data[table_word_r[x][y].x][table_word_r[x][y].y] = data.data[table_word_r[x][y].x][table_word_r[x][y].y]
							find_word(boxs[y])
							w_answer_list.append(Vector2(x, y))
					if r == 1:
						var z = randi_range(0, len(words_c_list) - 1)
						var x = words_c_list[z]
						var boxs = get_tree().get_nodes_in_group("answer_c_"+str(x))
						for y in range(boxs.size()):
							boxs[y].text = data.answers[1][x][y]
							answer_data[table_word_c[x][y].x][table_word_c[x][y].y] = data.data[table_word_c[x][y].x][table_word_c[x][y].y]
							find_word(boxs[y])
							w_answer_list.append(Vector2(x, y))
				elif words_c_list.size() > 0 and words_r_list.size() == 0:
					var z = randi_range(0, len(words_c_list) - 1)
					var x = words_c_list[z]
					var boxs = get_tree().get_nodes_in_group("answer_c_"+str(x))
					for y in range(boxs.size()):
						boxs[y].text = data.answers[1][x][y]
						find_word(boxs[y])
						answer_data[table_word_c[x][y].x][table_word_c[x][y].y] = data.data[table_word_c[x][y].x][table_word_c[x][y].y]
						w_answer_list.append(Vector2(x, y))
				elif words_r_list.size() > 0 and words_c_list.size() == 0:
					var z = randi_range(0, len(words_r_list) - 1)
					var x = words_r_list[z]
					var boxs = get_tree().get_nodes_in_group("answer_r_"+str(x))
					for y in range(boxs.size()):
						boxs[y].text = data.answers[0][data.answers[0].size() - x - 1][data.answers[0][data.answers[0].size() - x - 1].length() - y - 1]
						answer_data[table_word_r[x][y].x][table_word_r[x][y].y] = data.data[table_word_r[x][y].x][table_word_r[x][y].y]
						find_word(boxs[y])
						w_answer_list.append(Vector2(x, y))
			if data.state == 5:
				for btn in get_tree().get_nodes_in_group("guess_box"):
					if btn.text == btn.get_parent().get_meta("txt") and !btn.get_meta("static"):
						btn.set_meta("static", true)
						btn.get_child(0).emitting = true
						btn.get_meta("word").set_meta("static", true)
						btn.get_parent().set_meta("static", true)
						btn.mouse_entered.disconnect(btn.mouse_entered.get_connections()[0].callable)
						btn.mouse_exited.disconnect(btn.mouse_exited.get_connections()[0].callable)
						var style = $Label.get_theme_stylebox("normal")
						btn.add_theme_stylebox_override("normal", style)
						btn.add_theme_stylebox_override("pressed", style)
						btn.add_theme_stylebox_override("hover", style)
					else:
						if btn.text != btn.get_parent().get_meta("txt"):
							btn.get_node("AnimationPlayer").play("error")
			UpdateData.save("answer_data", answer_data)
			if words_list.size() == 1:
				await get_tree().create_timer(1.5).timeout
				win()
			if (words_c_list.size() == 0 and words_r_list.size() == 1) or (words_c_list.size() == 1 and words_r_list.size() == 0):
				await get_tree().create_timer(1.5).timeout
				win()
		if state == 2:
			true_answer_animation()
			if data.state == 0:
				for x in range(data.answers.size()):
					var hbox = get_tree().get_nodes_in_group("answer"+str(x))[0]
					for y in range(hbox.get_children().size()):
						find_word(hbox.get_child(y))
						hbox.get_child(y).text = data.answers[x][data.answers[x].length() - 1 - y]
			if data.state == 1:
				for box in table_box:
					get_tree().get_nodes_in_group("answer_"+str(box.x)+"_"+str(box.y))[0].text = data.data[box.x][box.y]
					find_word(get_tree().get_nodes_in_group("answer_"+str(box.x)+"_"+str(box.y))[0])
			if data.state == 5:
				for button in get_tree().get_nodes_in_group("word_box"):
					button.set_meta("static", false)
				for label in get_tree().get_nodes_in_group("box_answer"):
					if label.get_children().size() > 0:
						label.get_child(0).queue_free()
					for button in get_tree().get_nodes_in_group("word_box"):
						if label.get_meta("txt") == button.text and !button.get_meta("static"):
							button.set_meta("static", true)
							var btn = button.duplicate()
							btn.set_meta("id", label.get_meta("id"))
							btn.get_child(0).emitting = true
							var style = $Label.get_theme_stylebox("normal")
							btn.add_theme_stylebox_override("normal", style)
							btn.add_theme_stylebox_override("pressed", style)
							btn.add_theme_stylebox_override("hover", style)
							button.disabled = true
							button.mouse_filter = MOUSE_FILTER_IGNORE
							btn.disabled = false
							btn.position = Vector2(0, 0)
							btn.set_meta("word", button)
							btn.add_to_group("guess_box")
							btn.remove_from_group("word_box")
							label.add_child(btn)
							break
				await get_tree().create_timer(2).timeout
			await get_tree().create_timer(2).timeout
			win()
		
	else:
		$AnimationPlayer.play("score")
	
	

func save(_name, num):
	var confige = ConfigFile.new()
	confige.load(save_path)
	confige.set_value("user", _name, num)
	confige.save(save_path)
func load_game(_name, defaulte = null):
	var confige = ConfigFile.new()
	confige.load(save_path)
	return confige.get_value("user", _name, defaulte)
func _ready():
	set_process(false)
	var tex = load("res://sprite/user_img.png")
	if load_game("icon", "") != "":
		var image= Image.new()
		image.load("user://icons/"+load_game("icon", ""))
		tex = ImageTexture.create_from_image(image)
	$CanvasLayer/Panel/VBoxContainer/Control/TextureRect/TextureRect.texture = tex
	var http = HTTPRequest.new()
	add_child(http)
	http.request(UpdateData.protocol+UpdateData.subdomin+"/auth/AnswerNormal", UpdateData.get_header(), HTTPClient.METHOD_POST, JSON.stringify({}))
	score = int(load_game("score", 0))
	level = int(load_game("level", 1))
	update_score()
	part = int(load_game("part", 0))
	$CanvasLayer/Panel/VBoxContainer/Control/Label.text = load_game("name", "")
	answer_data = load_game("answer_data", [])
	UpdateData.save("level_data", [level, part])
	match part:
		0:
			unlock_level = await UpdateData.get_data("um", 1)
		1:
			unlock_level = await UpdateData.get_data("uh", 1)
		2:
			unlock_level = await UpdateData.get_data("us", 1)
		3:
			unlock_level = await UpdateData.get_data("uv", 1)
		4:
			unlock_level = await UpdateData.get_data("uve", 1)
	var p = ["mosque", "home", "school", "village", "VE"]
	data = await UpdateData.load_level("کاوش در منطقه", p[part], level)
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
	$Control/Label2.text = "مرحلـه " + str(level)
	$TextureRect3/Line2D.position = -$TextureRect3.global_position
	for node in get_tree().get_nodes_in_group("purchase"):
		if node is Button:
			node.text += str(await UpdateData.get_cost(node.get_meta("id", "")))
	if data.state == 0:
		var ans = data.answers
		var list = []
		for t in ans:
			list.append(t.length())
		var list2 = []
		var _size = list.size()
		for t in range(_size):
			list2.append(list.min())
			list.erase(list.min())
		var list3 = []
		for l in list2:
			for t in ans:
				if t.length() == l:
					list3.append(t)
					ans.erase(t)
					break
		var list4 = []
		var r = list2.size()
		if list2.size() > 6:
			r = (list2.size() / 2) + (list2.size() % 2)
			
		for l in range(r):
			if list2.size() > l + r:
				list4.append(list2[l] + list2[l + r])
		if list2.size() >= 5:
			max_size = 120
		elif  list2.size() > 6:
			max_size = ((8 - list4.max()) * 5) + 120
		data.answers = list3
		var vgrid = VGrid.new()
		vgrid.add_theme_constant_override("separation", 50)
		vgrid.layout_direction = Control.LAYOUT_DIRECTION_RTL
		vgrid.rows = r
		for x in range(data.answers.size()):
			add_answer(data.answers[x].length(), x, vgrid)
		$VBoxContainer/ScrollContainer.add_child(vgrid)
	else:
		add_answer(1, 0)
	$TextureRect/ScrollContainer/GridContainer.columns = $TextureRect/ScrollContainer.size.x / max_size
	if data.state != 5:
		for x in range(data.words.size()):
			add_words(data.words[x], (360 / data.words.size()) * x)
		words = data.words
		if words.size() < 20:
			$TextureRect3/Line2D.width = 30 - words.size()
		else:
			$TextureRect3/Line2D.width = 2
	else :
		for x in range(data.words.size()):
			add_words2(data.words[x], x)
	var quess = data.ques.split("؟")
	
	for x in range(quess.size()-1):
		$Node2D/Panel/PersianLabel.text += str(x+1) + "_" + quess[x] + "؟" + "\n"
	if data.state == 0:
		if answer_data.size() == 0:
			for x in range(data.answers.size()):
				var l = []
				for y in range(data.answers[x].length()):
					l.append("")
				answer_data.append(l)
				 
	
	if data.state == 1:
		if answer_data.size() == 0:
			for x in range(data.data.size()):
				var l = []
				for y in range(data.data[x].size()):
					l.append("")
				answer_data.append(l)
	if data.state == 5:
		$CanvasLayer/Panel/VBoxContainer/Button6.show()
		$CanvasLayer/Panel/VBoxContainer/Button4.hide()
		$VBoxContainer.hide()
		$TextureRect.show()
		$label_pos.hide()
		$TextureRect3.hide()
		$TextureButton.hide()
	emit_signal("start")
	set_process(true)
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		UpdateData.save("answer_data", answer_data)
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and not get_tree().has_group("menu_levels"):
		_on_button_5_pressed()
func add_words(_name, degross):
	var label = preload("res://scenes/Label.tscn").instantiate()
	var node = Node2D.new()
	label.size2 = 100 -  (words.size() * 2)
	label.size = Vector2(.7 * label.size2, label.size2 + 1)
	label.text = _name
	
	label.mouse_hover.connect(_on_Label_mouse_hover)
	label.mouse_exit.connect(_on_Label_mouse_exit)
	label.position = -label.size / 2
	node.add_child(label)
	
	var pivot = Vector2(0, .64).rotated(deg_to_rad(degross))
	var size2 = ($TextureRect3.size / 2)
	node.position = -(pivot * size2)

	$TextureRect3/words.add_child(node)
func add_words2(_name, x):
	var label = $Label3.duplicate()
	label.add_to_group("word_box")
	label.show()
	label.custom_minimum_size = Vector2.ONE * max_size
	label.set_meta("num", x)
	label.add_theme_font_size_override("font_size", 60 * (max_size / 100.0))
	label.text = _name
	label.set_meta("static", false)
	label.mouse_entered.connect(func():
		
		if !current_word.has(label) and !current_btn:
			current_word.append(label)
		
		if current_word.size() > 0 and current_word[0]==label:
			current_word_exit = false
	)

	label.mouse_exited.connect(func():
		
		if current_word.has(label) and !label.disabled:
			current_word.erase(label)
		if current_word.size() > 0 and current_word[0] == label:
			current_word_exit = true
	)
	$TextureRect/ScrollContainer/GridContainer.add_child(label)

func add_answer(num, count, parent=$VBoxContainer/ScrollContainer/GridBoxContainer):
	var l = []
	var q = []
	if data.state == 0:
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hbox.layout_direction = Control.LAYOUT_DIRECTION_LTR
		for x in range(num):
			var box = preload("res://scenes/box_word.tscn").instantiate()
			box.custom_minimum_size = Vector2.ONE * max_size
			box.label_settings.font_size = 60 * (max_size / 100.0)
			box.get_child(0).position = Vector2(max_size / 2, max_size)
			
			hbox.add_child(box)
		hbox.add_theme_constant_override("separation", 0)
		hbox.add_to_group("answer"+str(count))
		parent.add_child(hbox)
		
		
	elif  data.state == 1:
		
		$VBoxContainer/ScrollContainer/GridBoxContainer.layout_direction = LAYOUT_DIRECTION_LTR
		$VBoxContainer/ScrollContainer.layout_direction = LAYOUT_DIRECTION_LTR
		$VBoxContainer/ScrollContainer/GridBoxContainer.columns = data.data.size()
		max_size = ((8 - data.data.size()) * 5) + 120
		$VBoxContainer/ScrollContainer/GridBoxContainer.add_theme_constant_override("v_separation" , 0)
		$VBoxContainer/ScrollContainer/GridBoxContainer.add_theme_constant_override("h_separation" , 0)
		
		for x in range(data.data.size()):
			for y in range(data.data[x].size()):
				var control = Control.new()
				control.mouse_filter = Control.MOUSE_FILTER_IGNORE
				var box = preload("res://scenes/box_word.tscn").instantiate()
				box.custom_minimum_size = Vector2.ONE * max_size
				box.label_settings.font_size = 60 * (max_size / 100.0)
				box.get_child(0).position = Vector2(max_size / 2, max_size)
				control.custom_minimum_size = box.custom_minimum_size
				for c in range(data.answers[2].size()):
					if x == 0 and y == 0 and "_00_" in data.answers[2][c]:
						box.add_to_group("answer_c_"+str(c))
						l.append([Vector2(x, y), c])
					elif ("_" + str(y + (x * data.data[x].size())) + "_") in data.answers[2][c]:
						l.append([Vector2(x, y), c])
						box.add_to_group("answer_c_"+str(c))

				for r in range(data.answers[3].size()):
					
					if x == 0 and y == 0 and "_00_" in data.answers[3][r]:
						box.add_to_group("answer_r_"+str(r))
						q.append([Vector2(x, y), r])
					elif ("_" + str(y + (x * data.data[x].size())) + "_") in data.answers[3][r]:
						box.add_to_group("answer_r_"+str(r))
						q.append([Vector2(x, y), r])
				if data.data[x][y] != " ":
					table_box.append(Vector2(x, y))
					box.add_to_group("answer_"+str(x)+"_"+str(y))
					$VBoxContainer/ScrollContainer/GridBoxContainer.add_child(box)
				else:
					$VBoxContainer/ScrollContainer/GridBoxContainer.add_child(control)
		for y in range(data.answers[3].size()):
			var z = []
			for x in range(q.size()):
				if q[x][1] == y:
					z.append(q[x][0])
			table_word_r.append(z)
		for y in range(data.answers[2].size()):
			var z = []
			for x in range(l.size()):
				if l[x][1] == y:
					z.append(l[x][0])
			table_word_c.append(z)
	else:
	
		max_size = $VBoxContainer.size.x / data.size
		
		$ScrollContainer/VBoxContainer.add_theme_constant_override("separation", -max_size / 4)
		var id = 0
		for x in range(data.size):
			var hbox = HBoxContainer.new()
			hbox.add_theme_constant_override("separation", -4)
			if x % 2 == 1:
				var c = Control.new()
				c.custom_minimum_size.x = max_size / 2
				hbox.add_child(c)
			for y in range(data.size):
				var box = Control.new()
				
				for a in data.data:
					var pos = Vector2(int(a[2].split(",")[0]), int(a[2].split(",")[1]))
					if x == pos.x and y == pos.y:
						if !a[1]:
							
							box = $Label.duplicate()
							box.size = Vector2.ONE * (max_size)
							box.text = a[0]
						else:
							id += 1
							
							box = $Label2.duplicate()
							box.set_meta("pos", a[2])
							box.set_meta("id", id)
							box.size = Vector2.ONE * (max_size)
							box.add_to_group("box_answer")
							box.mouse_entered.connect(func():
								target = box
								)
							box.mouse_exited.connect(func():
								if target == box:
									target = null)
						box.set_meta("txt", a[0])
						box.show()
						box.label_settings.font_size = 60 * (max_size / 100.0)
				box.custom_minimum_size = Vector2.ONE * max_size
				box.add_to_group("arrange")
				box.set_meta("x", x)
				box.set_meta("y", y)
				hbox.add_child(box)
			$ScrollContainer/VBoxContainer.add_child(hbox)
func get_node_in_group(group_name, id):
	if get_tree().has_group(group_name):
		for node in get_tree().get_nodes_in_group(group_name):
			if node.get_meta("id") == id:
				return node
	return null
func win(wait=0):
	if !winer:
		winer = true
		set_process(false)
		if wait != 0:
			await get_tree().create_timer(wait).timeout
		var w = preload("res://scenes/win.tscn").instantiate()
		var p = ["m", "h", "s", "v", "ve"]
		var d = {}
		var r = HTTPRequest.new()
		add_child(r)
		r.timeout = 3
		r.request(UpdateData.protocol+UpdateData.subdomin+"/auth/AnswerNormal", UpdateData.get_header(), HTTPClient.METHOD_POST, JSON.stringify({"data":answer_data}))
		var result = await r.request_completed
		var json = UpdateData.get_json(result[3])
		if json is Dictionary and json.has("num"):
			w.score = json["num"]
			save("score", score+json["num"])
		if level + 1 > unlock_level and level >= max_level:
			if int(part) >= int(load_game("unlock_part", 0)):
				d["unlock_part"] = part + 1
		d["answer_data"] = []
		UpdateData.multy_save(d)
		get_tree().get_root().add_child(w)
		queue_free()
func change_words_pos():
	var list = []
	var words2 = data.words
	randomize()
	for y in range(words2.size()):
		var x = randi_range(0, words2.size() - 1)
		list.append(words2[x])
		words2.remove_at(x)
	data.words = list
	for child in $TextureRect3/words.get_children():
		child.queue_free()
	for x in range(data.words.size()):
		add_words(data.words[x], (360 / data.words.size()) * x)
	
func _process(delta):
	if data.state == 0 and ready2:
		ready2 = false
		if answer_data.size() == data.answers.size():
			for x in range(answer_data.size()):
				var hbox = get_tree().get_nodes_in_group("answer"+str(x))[0]
				var a = true
				var c = true
				if answer_data[x].size() == data.answers[x].length():
					for z in range(answer_data[x].size()):
						if answer_data[x][z] == "":
							a = false
						elif answer_data[x][answer_data[x].size() - 1 - z] != data.answers[x][z]:
							c = false
					for y in range(hbox.get_children().size()):
						if answer_data[x][y] != "" and c:
							w_answer_list.append(Vector2(x, y))
							hbox.get_child(y).text = answer_data[x][y]
						if a and c:
							find_word(hbox.get_child(y))
				else:
					answer_data[x].resize(data.answers[x].length())
					for y in range(answer_data[x].size()):
						answer_data[x][y] = ""
		else:
			answer_data = []
			for x in range(data.answers.size()):
				var l = []
				for y in range(data.answers[x].length()):
					l.append("")
				answer_data.append(l)
		UpdateData.save("answer_data", answer_data)
	if data.state == 1 and ready2:
		ready2 = false
		if data.data.size() == answer_data.size():
			for box in table_box:
				if answer_data[box.x][box.y] != "" and answer_data[box.x][box.y] == data.data[box.x][box.y]:
					get_tree().get_nodes_in_group("answer_"+str(box.x)+"_"+str(box.y))[0].text = data.data[box.x][box.y]
					find_word(get_tree().get_nodes_in_group("answer_"+str(box.x)+"_"+str(box.y))[0])
		else :
			answer_data = []
			for x in range(data.data.size()):
				var l = []
				for y in range(data.data[x].size()):
					l.append("")
				answer_data.append(l)
			UpdateData.save("answer_data", answer_data)
	if data.state == 5 and ready2:
		ready2 = false
		if answer_data.size() != 0:
			for b in answer_data:
				for button in get_tree().get_nodes_in_group("word_box"):
					if button.get_meta("num") == b[0]:
						var btn = button.duplicate()
						if b[2]:
							btn.get_child(0).emitting = true
							var style = $Label.get_theme_stylebox("normal")
							btn.add_theme_stylebox_override("normal", style)
							btn.add_theme_stylebox_override("pressed", style)
							btn.add_theme_stylebox_override("hover", style)
						button.disabled = true
						btn.disabled = false
						btn.position = Vector2(0, 0)
						button.mouse_filter = MOUSE_FILTER_IGNORE
						btn.set_meta("word", button)
						btn.set_meta("static", bool(b[2]))
						button.set_meta("static", bool(b[2]))
						btn.add_to_group("guess_box")
						btn.remove_from_group("word_box")
						var t 
						for a in get_tree().get_nodes_in_group("box_answer"):
							if a.get_meta("id") == b[1]:
								t = a
						if t:
							btn.set_meta("id", t.get_meta("id"))
							if !b[2]:
								btn.mouse_entered.connect(func ():
									if current_word2 != btn:
										current_word2 = btn)
								btn.mouse_exited.connect(func ():
									if current_word2 == btn:
										current_word2 = null)
							t.add_child(btn)
	if rotate_words:
		speed_rotate += 10 * delta
		$TextureRect3/words.rotate(deg_to_rad(speed_rotate))
		if speed_rotate >= 10:
			back_rotate_words = true
			rotate_words = false
			change_words_pos()
	if back_rotate_words:
		speed_rotate -= 10 * delta
		$TextureRect3/words.rotate(deg_to_rad(speed_rotate))
		if speed_rotate <= 1:
			speed_rotate = 0
			if $TextureRect3/words.rotation != 0:
				stop_rotate_words = true
			back_rotate_words = false
	if stop_rotate_words:
		
		if int(rad_to_deg($TextureRect3/words.rotation)) % 360 != 0:
			if int(rad_to_deg($TextureRect3/words.rotation)) % 360 != 180:
				$TextureRect3/words.rotate(deg_to_rad(-(180 - (int(rad_to_deg($TextureRect3/words.rotation)) % 360)) / abs(180 - (int(rad_to_deg($TextureRect3/words.rotation)) % 360))))
			else:
				$TextureRect3/words.rotate(deg_to_rad(1))
		else:
			$TextureRect3/words.rotation = 0
			stop_rotate_words = false
			drag = true
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if data.state != 5:
			if drag:
				$label_pos/Label.add_theme_stylebox_override("normal", preload("res://styles/word_label_n2.tres"))
				true_answer = false
				answered = false
				if word:
					if !target_word.has(word):
						target_word.append(word)
				$TextureRect3/Line2D.points = []
				for words2 in target_word:
					$TextureRect3/Line2D.add_point(words2.global_position + words2.size / 2)
				$TextureRect3/Line2D.add_point(get_global_mouse_position())
				if $TextureRect3/Line2D.points.size() > 0:
					$TextureRect3/Line2D.set_point_position(len($TextureRect3/Line2D.points) - 1, get_global_mouse_position())
				text = ""
				for words2 in target_word:
					text += words2.text
				$label_pos/Label.text = text
		else:
			if current_word2:
				current_btn = current_word2
			elif current_word.size() > 0:
				if !current_word[0].disabled:
					current_word[0].disabled = true
					
					current_btn = current_word[0].duplicate()
					current_btn.mouse_filter = MOUSE_FILTER_IGNORE
					current_btn.disabled = false
					add_child(current_btn)
					
			if current_btn:
				current_btn.z_index = 1
				current_btn.global_position = get_global_mouse_position() - current_btn.size / 2
				if get_tree().has_group("guess_box"):
					for btn in get_tree().get_nodes_in_group("guess_box"):
						if btn.get_meta("static") == false:
							btn.mouse_filter = MOUSE_FILTER_IGNORE
	else:
		if current_btn:
			if target:
				var btn = current_btn.duplicate()
				btn.position = Vector2(0, 0)
				if current_word.size() > 0:
					btn.set_meta("word", current_word[0])
					btn.add_to_group("guess_box")
				btn.set_meta("id", target.get_meta("id"))
				
				btn.mouse_entered.connect(func ():
					if current_word2 != btn:
						current_word2 = btn)
				btn.mouse_exited.connect(func ():
					if current_word2 == btn:
						current_word2 = null)
				
				if target.get_children().size() > 0 and target.get_child(0) != current_btn:
					if current_btn.get_meta("id") == null:
						target.get_child(0).get_meta("word").disabled = false
						target.get_child(0).get_meta("word").mouse_filter = MOUSE_FILTER_STOP
						target.get_child(0).queue_free()
					else:
						var btn2 = target.get_child(0).duplicate()
						var t = get_node_in_group("box_answer", current_btn.get_meta("id"))
						btn2.set_meta("id", t.get_meta("id"))
						btn2.mouse_entered.connect(func ():
							if current_word2 != btn2:
								current_word2 = btn2)
						btn2.mouse_exited.connect(func ():
							if current_word2 == btn2:
								current_word2 = null)
						t.add_child(btn2)
						target.get_child(0).queue_free()
				target.add_child(btn)
				target = null
				current_btn.queue_free()
				current_btn = null
				if current_word.size() > 0:
					current_word[0].mouse_filter = MOUSE_FILTER_IGNORE
					current_word = []
					current_word_exit = false
			else :
				if current_word.size() > 0:
					current_word[0].disabled = false
					if current_word_exit:
						current_word_exit = false
						current_word.remove_at(0)
				else :
					current_btn.get_meta("word").disabled = false
					current_btn.get_meta("word").mouse_filter = MOUSE_FILTER_STOP
				current_btn.queue_free()
				current_btn = null
		else :
			if data.state == 5:
				answer_data = []
			var g = []
			if get_tree().has_group("guess_box"):
				for btn in get_tree().get_nodes_in_group("guess_box"):
					if !btn.get_meta("static"):
						g.append(btn)
					answer_data.append([btn.get_meta("num", 1), btn.get_meta("id", 1), btn.get_meta("static", false), btn.text, btn.get_parent().get_meta("pos")])
					btn.mouse_filter = MOUSE_FILTER_STOP
					btn.z_index = 0
			$CanvasLayer/Panel/VBoxContainer/Button6.disabled = g.size() == 0
		var next_level = true
		if data.state == 0:
			for x in range(data.answers.size()):
				var hbox = get_tree().get_nodes_in_group("answer"+str(x))[0]
				if text == data.answers[x]:
					for y in range(hbox.get_children().size()):
						if hbox.get_child(y).text == "":
							true_answer = true
							hbox.get_child(y).text = data.answers[x][data.answers[x].length() - 1 - y]
							w_answer_list.append(Vector2(x, y))
							answer_data[x][y] = data.answers[x][data.answers[x].length() - 1 - y]
							UpdateData.save("answer_data", answer_data)
							find_word(hbox.get_child(y))
						else:
							answered = true
				for y in range(hbox.get_children().size()):
					
					if hbox.get_child(y).text == "":
						next_level = false
		if data.state == 1:
			for x in range(data.answers[0].size()):
				var boxs = get_tree().get_nodes_in_group("answer_r_"+str(x))
				if text == data.answers[0][data.answers[0].size() - x - 1]:
					for y in range(boxs.size()):
						if boxs[y].text == "":
							true_answer = true
							boxs[y].text = data.answers[0][data.answers[0].size() - x - 1][data.answers[0][data.answers[0].size() - x - 1].length() - y - 1]
							answer_data[table_word_r[x][y].x][table_word_r[x][y].y] = data.data[table_word_r[x][y].x][table_word_r[x][y].y]
							find_word(boxs[y])
							UpdateData.save("answer_data", answer_data)
							w_answer_list.append(Vector2(x, y))
						else:
							answered = true
				for y in range(boxs.size()):
					if boxs[y].text == "":
						next_level = false
			for x in range(data.answers[1].size()):
				var boxs = get_tree().get_nodes_in_group("answer_c_"+str(x))
				if text == data.answers[1][x]:
					for y in range(boxs.size()):
						if boxs[y].text == "":
							true_answer = true
							boxs[y].text = data.answers[1][x][y]
							answer_data[table_word_c[x][y].x][table_word_c[x][y].y] = data.data[table_word_c[x][y].x][table_word_c[x][y].y]
							UpdateData.save("answer_data", answer_data)
							find_word(boxs[y])
							w_answer_list.append(Vector2(x, y))
						else:
							answered = true
				for y in range(boxs.size()):
					if boxs[y].text == "":
						next_level = false
		if data.state == 5:
			
			for box in get_tree().get_nodes_in_group("box_answer"):
				if box.get_children().size() > 0:
					if box.get_meta("txt") != box.get_child(0).text:
						next_level = false
				else :
					next_level = false
			if next_level:
				if gui_input.is_connected(_on_gui_input):
					gui_input.disconnect(_on_gui_input)
					$PersianButton2.pressed.disconnect(_on_PersianButton2_pressed)
				for btn in get_tree().get_nodes_in_group("guess_box"):
					if !btn.get_meta("static"):
						btn.set_meta("static", true)
						btn.mouse_filter = MOUSE_FILTER_IGNORE
						btn.get_child(0).emitting  = true
						
		if text != "":
			drag = false
			if true_answer:
				$Timer.start()
				true_answer_animation()
				$label_pos/Label.add_theme_stylebox_override("normal", preload("res://styles/word_label_t2.tres"))
			elif answered:
				$label_pos/Label.add_theme_stylebox_override("normal", preload("res://styles/word_label_b2.tres"))
			else:
				$label_pos/Label.add_theme_stylebox_override("normal", preload("res://styles/word_label_f2.tres"))
			target_word = []
			$TextureRect3/Line2D.points = []
			drag = true
		if next_level:
			await get_tree().create_timer(1).timeout
			win(2)
				
	$label_pos.global_position.y = $TextureRect3.global_position.y - $label_pos/Label.size.y
	$label_pos.global_position.x = ($TextureRect3.global_position.x + $TextureRect3.size.x / 2) - $label_pos/Label.size.x / 2



func _on_Label_mouse_exit(object):
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target_word.erase(object)
	word = null

func _on_Label_mouse_hover(object):
	if !target_word.has(object) and drag:
		target_word.append(object)
	


func _on_PersianButton_pressed():
	UpdateData.save("answer_data", answer_data)
	var m = preload("res://scenes/menu_levels.tscn").instantiate()
	m.p_scene = self
	hide()
	get_tree().get_root().add_child(m)
	menu_open = false
	$CanvasLayer/Panel/AnimationPlayer.play("close")

func _on_PersianButton2_pressed():
	menu_open = true
	$CanvasLayer/Panel/AnimationPlayer.play("open")


func _on_TextureButton_pressed():
	if !rotate_words and !stop_rotate_words and !back_rotate_words:
		rotate_words = true
		drag = false


func _on_button_5_pressed():
	UpdateData.save("answer_data", answer_data)
	Exit.change_scene("res://scenes/start.tscn")


func true_answer_animation():
	$bee/AnimationPlayer.play("true_answer")
	
	await $bee/AnimationPlayer.animation_finished
	true_answer = false
	if !drag:
		text = ""
		$label_pos/Label.text = text
func _on_help_button_pressed(state, _score, id):
	help(state, _score, id)
	menu_open = false
	$CanvasLayer/Panel/AnimationPlayer.play("close")


func _on_texture_button_pressed():
	menu_open = false
	$CanvasLayer/Panel/AnimationPlayer.play("close")



func _on_button_pressed():
	
	if !ques_menu:
		$AnimationPlayer2.play("question")
		ques_menu = true
		
	else:
		$AnimationPlayer2.play_backwards("question")
		await $AnimationPlayer2.animation_finished
		ques_menu = false
		
func _on_button_2_pressed():
	$AnimationPlayer2.play_backwards("question")
	ques_menu = false

func _on_gui_input(event):
	if event is InputEventScreenTouch:
		if menu_open and !$CanvasLayer/Panel/AnimationPlayer.is_playing():
			menu_open = false
			$CanvasLayer/Panel/AnimationPlayer.play("close")
		if ques_menu:
			$AnimationPlayer2.play_backwards("question")
			ques_menu = false
		
	if !menu_open:
		if event is InputEventScreenDrag:
			if event.position.x < 200 and event.relative.x > 10 and target_word.size() == 0:
				menu_open = true
				$CanvasLayer/Panel/AnimationPlayer.play("open")

func _on_timer_timeout():
	pass
	
